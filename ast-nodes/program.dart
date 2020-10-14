import 'dart:ffi';
import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A program is a list of [Declaration]s.
///
/// Declarations can be of three types:
///  - [VariableDeclaration]s
///  - [TypeDeclaration]s
///  - [RoutineDeclaration]s
class Program implements Node, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  List<Declaration> declarations;

  Program(this.declarations);

  factory Program.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    var declarations = <Declaration>[];

    var hadSemicolonBefore = false;

    while (iterator.moveNext()) {
      if (iterator.current.value == 'routine') {
        var routineTokens = consumeAwareUntil(
          iterator,
          RegExp('(record|while|for|if)\$'),
          RegExp('end\$'),
          RegExp('end\$'),
        );
        routineTokens.add(iterator.current);
        declarations.add(Declaration.parse(routineTokens));

        if (!iterator.moveNext()) {
          break;
        }

        if (iterator.current.value == ';') {
          hadSemicolonBefore = true;
        } else if (iterator.current.value == '\n') {
          hadSemicolonBefore = false;
        } else {
          throw SyntaxError(
              iterator.current, "Expected a newline or a semicolon");
        }
      } else {
        var declarationTokens = <Token>[];
        var recordCount = 0;
        do {
          if (iterator.current.value == 'record') {
            recordCount++;
          } else if (iterator.current.value == 'end') {
            recordCount--;
          }
          if ((iterator.current.value == ';' ||
                  iterator.current.value == '\n') &&
              recordCount == 0) {
            break;
          }

          declarationTokens.add(iterator.current);
        } while (iterator.moveNext());

        if (declarationTokens.isEmpty) {
          if (iterator.current.value == ';' && hadSemicolonBefore) {
            throw SyntaxError(iterator.current, 'Expected declaration');
          } else {
            continue;
          }
        }

        declarations.add(Declaration.parse(declarationTokens));
      }
    }

    return Program(declarations);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Program', depth) +
        drawDepth('declarations:', depth + 1) +
        this
            .declarations
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  Scope buildSymbolTable() {
    this.propagateScopeMark(null);
    return this.scopes[0];
  }

  void propagateScopeMark(ScopeElement parentMark) {
    var scope = Scope();
    this.scopes = [scope];
    var currentMark = scope.lastChild;
    currentMark = scope.addDeclaration(BuiltinRoutineDeclaration(
        "print", [Parameter("value", IntegerType())], null));

    for (var declaration in this.declarations) {
      declaration.propagateScopeMark(currentMark);
      currentMark = scope.addDeclaration(declaration);

      if (declaration is ScopeCreator) {
        (declaration as ScopeCreator)
            .scopes
            .forEach((subscope) => scope.addSubscope(subscope));
      }
    }
  }

  void checkSemantics() {
    for (var declaration in this.declarations) {
      declaration.checkSemantics();
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    for (var declaration in this.declarations) {
      if (declaration is TypeDeclaration) {
        continue;
      }
      declaration.generateCode(module);
    }
    return null;
  }

  /// Generate the main routine with basic I/O.
  ///
  /// This routine will read the routine name from command-line arguments and output the integer
  /// result of the executed routine.
  Map<String, Pointer<LLVMOpaqueBasicBlock>> generateEntrypoint(Module module) {
    var entrypoint = module.addRoutine('main', getEntrypointSignature(module));
    var argc = llvm.LLVMGetParam(entrypoint, 0);
    var argv = llvm.LLVMGetParam(entrypoint, 1);

    // Check if the entry routine name is passed as a cmdline argument.
    var argcCheck = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      entrypoint,
      MemoryManager.getCString('argc-check'),
    );

    // if (argc == 2)
    llvm.LLVMPositionBuilderAtEnd(module.builder, argcCheck);
    var comparisonResult = llvm.LLVMBuildICmp(
      module.builder,
      LLVMIntPredicate.LLVMIntEQ,
      argc,
      llvm.LLVMConstInt(
        IntegerType().getLlvmType(module),
        2,
        1,  // SignExtend: true
      ),
      MemoryManager.getCString("argc-check"),
    );

    var argcError = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      entrypoint,
      MemoryManager.getCString('argc-error'),
    );
    var argcPass = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      entrypoint,
      MemoryManager.getCString('argc-pass'),
    );
    llvm.LLVMBuildCondBr(module.builder, comparisonResult, argcPass, argcError);

    // else printf("Exactly 1 argument expected.\n");
    llvm.LLVMPositionBuilderAtEnd(module.builder, argcError);
    var args = MemoryManager.getArray(1).cast<Pointer<LLVMOpaqueValue>>();
    args.elementAt(0).value = llvm.LLVMBuildGlobalStringPtr(
      module.builder,
      MemoryManager.getCString('Exactly 1 argument expected.\n'),
      MemoryManager.getCString('argc-error-str'),
    );
    llvm.LLVMBuildCall2(
      module.builder,
      module.printfSignature,
      module.printf,
      args,
      1,
      MemoryManager.getCString('printf-argc-error-str'),
    );
    llvm.LLVMBuildRet(module.builder, llvm.LLVMConstInt(
      IntegerType().getLlvmType(module),
      1,
      1,  // SignExtend: true
    ));

    // Get argv[1]
    llvm.LLVMPositionBuilderAtEnd(module.builder, argcPass);
    var indices = MemoryManager.getArray(1).cast<Pointer<LLVMOpaqueValue>>();
    indices.elementAt(0).value = llvm.LLVMConstInt(
      llvm.LLVMInt64TypeInContext(module.context),
      1,
      0,  // SignExtend: false
    );
    var string = llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0);
    var argAddress = llvm.LLVMBuildInBoundsGEP2(
      module.builder,
      string,
      argv,
      indices,
      1,
      MemoryManager.getCString('argv-indexing')
    );
    var proposedRoutineName = llvm.LLVMBuildLoad2(
      module.builder,
      llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0),
      argAddress,
      MemoryManager.getCString('first-argument')
    );

    var tests = <String, Pointer<LLVMOpaqueBasicBlock>>{};
    var calls = <String, Pointer<LLVMOpaqueBasicBlock>>{};
    var nameStrings = <String, Pointer<LLVMOpaqueValue>>{};
    var routineNames = this
        .declarations
        .where((declaration) => declaration is RoutineDeclaration)
        .map((declaration) => declaration.name)
        .toList();

    var lastBlock = argcPass;
    String lastName = null;
    Pointer<LLVMOpaqueValue> lastComparisonResult;
    for (var name in routineNames) {
      tests[name] = llvm.LLVMAppendBasicBlockInContext(
        module.context,
        entrypoint,
        MemoryManager.getCString('test:$name'),
      );
      calls[name] = llvm.LLVMAppendBasicBlockInContext(
        module.context,
        entrypoint,
        MemoryManager.getCString('call:$name'),
      );
      nameStrings[name] = llvm.LLVMBuildGlobalStringPtr(
        module.builder,
        MemoryManager.getCString(name),
        MemoryManager.getCString('name:$name'),
      );

      if (lastName == null) {
        llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
        llvm.LLVMBuildBr(module.builder, tests[name]);
      } else {
        llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
        llvm.LLVMBuildCondBr(module.builder, lastComparisonResult, calls[lastName], tests[name]);
      }

      llvm.LLVMPositionBuilderAtEnd(module.builder, tests[name]);

      var args = MemoryManager.getArray(2).cast<Pointer<LLVMOpaqueValue>>();
      args.elementAt(1).value = proposedRoutineName;
      args.elementAt(0).value = nameStrings[name];
      var strcmpResult = llvm.LLVMBuildCall2(
        module.builder,
        module.strcmpSignature,
        module.strcmp,
        args,
        2,
        MemoryManager.getCString('strcmp-call')
      );
      lastComparisonResult = llvm.LLVMBuildICmp(
        module.builder,
        LLVMIntPredicate.LLVMIntEQ,
        strcmpResult,
        llvm.LLVMConstInt(
          IntegerType().getLlvmType(module),
          0,
          1
        ),
        MemoryManager.getCString('strcmp-test')
      );

      lastBlock = tests[name];
      lastName = name;
    }

    var testError = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      entrypoint,
      MemoryManager.getCString('test-error'),
    );
    llvm.LLVMPositionBuilderAtEnd(module.builder, testError);
    args = MemoryManager.getArray(2).cast<Pointer<LLVMOpaqueValue>>();
    args.elementAt(0).value = llvm.LLVMBuildGlobalStringPtr(
      module.builder,
      MemoryManager.getCString('Can\'t find a routine with the name \'%s\'.\n'),
      MemoryManager.getCString('test-error-str'),
    );
    args.elementAt(1).value = proposedRoutineName;
    llvm.LLVMBuildCall2(
      module.builder,
      module.printfSignature,
      module.printf,
      args,
      1,
      MemoryManager.getCString('printf-test-error-str'),
    );
    llvm.LLVMBuildRet(module.builder, llvm.LLVMConstInt(
      IntegerType().getLlvmType(module),
      1,
      1,  // SignExtend: true
    ));

    llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
    llvm.LLVMBuildCondBr(module.builder, lastComparisonResult, calls[lastName], testError);
    return calls;
  }

  void wireUpRoutines(Module module, Map<String, Pointer<LLVMOpaqueBasicBlock>> callBlocks) {
    var args = MemoryManager.getArray(2).cast<Pointer<LLVMOpaqueValue>>();
    args.elementAt(0).value = llvm.LLVMBuildGlobalStringPtr(
      module.builder,
      MemoryManager.getCString('Output: %d.\n'),
      MemoryManager.getCString('output-format'),
    );

    for (var routine in callBlocks.keys) {
      RoutineDeclaration declaration = this.declarations.firstWhere((decl) => decl.name == routine);
      llvm.LLVMPositionBuilderAtEnd(module.builder, callBlocks[routine]);
      var val = llvm.LLVMBuildCall2(
        module.builder,
        declaration.signature,
        declaration.valueRef,
        nullptr,
        0,
        MemoryManager.getCString('call-$routine'),
      );
      args.elementAt(1).value = val;
      llvm.LLVMBuildCall2(
        module.builder,
        module.printfSignature,
        module.printf,
        args,
        2,
        MemoryManager.getCString('printf-output'),
      );
      llvm.LLVMBuildRet(module.builder, llvm.LLVMConstInt(
        IntegerType().getLlvmType(module),
        0,
        1,  // SignExtend: true
      ));
    }
  }
}
