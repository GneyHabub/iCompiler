import 'dart:ffi';
import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A routine declaration has [parameters], a [returnType] and a [body].
class RoutineDeclaration extends Declaration implements ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  List<Parameter> parameters;
  VarType returnType;
  List<Statement> body;

  bool hasReturnStatement = false;
  Pointer<LLVMOpaqueType> signature;
  Pointer<LLVMOpaqueValue> valueRef;

  RoutineDeclaration(name, this.parameters, this.returnType, this.body)
      : super(name);

  factory RoutineDeclaration.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('routine\$'), "Expected 'routine'");
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var routineName = iterator.current.value;
    if (isReserved(routineName)) {
      throw SyntaxError(
          iterator.current, "The '$routineName' keyword is reserved");
    }

    checkNext(iterator, RegExp("\\("), "Expected '('");
    iterator.moveNext();
    var parameterTokens = consumeUntil(iterator, RegExp("\\)\$"));
    checkThis(iterator, RegExp("\\)"), "Expected ')'");
    iterator.moveNext();

    VarType returnType = null;
    if (iterator.current?.value == ":") {
      iterator.moveNext();
      returnType = VarType.parse(consumeAwareUntil(
          iterator, RegExp('record\$'), RegExp('end\$'), RegExp('is\$')));
    }

    checkThis(iterator, RegExp('is\$'), "Expected 'is'");
    iterator.moveNext();
    var body = Statement.parseBody(consumeAwareUntil(
      iterator,
      RegExp('(record|if|while|for)\$'),
      RegExp('end\$'),
      RegExp('end\$'),
    ));

    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var parameters = <Parameter>[];
    var parsIterator = parameterTokens.iterator;
    while (parsIterator.moveNext()) {
      var blockTokens = consumeUntil(parsIterator, RegExp(",\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      parameters.add(Parameter.parse(blockTokens));
    }

    return RoutineDeclaration(routineName, parameters, returnType, body);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}RoutineDeclaration("${this.name}")', depth) +
        drawDepth('parameters:', depth + 1) +
        this
            .parameters
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join('') +
        (this.returnType?.toString(depth: depth + 1, prefix: 'return type: ') ??
            '') +
        drawDepth('body:', depth + 1) +
        this
            .body
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.lastChild;

    for (var parameter in this.parameters) {
      parameter.propagateScopeMark(parentMark);
      currentMark = scope.addDeclaration(parameter.toDeclaration());
    }
    this.returnType?.propagateScopeMark(parentMark);

    for (var statement in this.body) {
      statement.propagateScopeMark(currentMark);
      if (statement is Declaration) {
        currentMark = scope.addDeclaration(statement);
      }

      if (statement is ScopeCreator) {
        (statement as ScopeCreator)
            .scopes
            .forEach((subscope) => scope.addSubscope(subscope));
      }
    }
  }

  void checkSemantics() {
    this.scopeMark.ensureNoOther(this.name);

    for (var parameter in this.parameters) {
      parameter.checkSemantics();
    }

    this.returnType?.checkSemantics();

    for (var statement in this.body) {
      statement.checkSemantics();
    }

    if (!this.hasReturnStatement && this.returnType != null) {
      throw SemanticError(
          this, "The function has a return type but no return statements");
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    module.isGlobal = false;
    var paramTypes = MemoryManager.getArray(this.parameters.length)
        .cast<Pointer<LLVMOpaqueType>>();
    for (var i = 0; i < this.parameters.length; i++) {
      paramTypes.elementAt(i).value =
          this.parameters[i].type.getLlvmType(module);
    }

    this.signature = llvm.LLVMFunctionType(
      this.returnType?.getLlvmType(module) ??
          llvm.LLVMVoidTypeInContext(module.context),
      paramTypes,
      this.parameters.length,
      0, // IsVariadic: false
    );

    this.valueRef = module.addRoutine(
      this.name,
      this.signature,
    );

    for (var i = 0; i < this.parameters.length; i++) {
      var parameter = llvm.LLVMGetParam(this.valueRef, i);
      llvm.LLVMSetValueName2(
          parameter,
          MemoryManager.getCString(parameters[i].name),
          parameters[i].name.length);
    }
    var paramAllocBlock = llvm.LLVMAppendBasicBlock(this.valueRef, MemoryManager.getCString('initialize_parameters'));
    llvm.LLVMPositionBuilderAtEnd(module.builder, paramAllocBlock);
    for (var parameter in this.parameters) {
      this.scopes[0].lastChild.resolve(parameter.name).valueRef = llvm.LLVMBuildAlloca(
        module.builder,
        parameter.type.resolve().getLlvmType(module),
        MemoryManager.getCString(parameter.name)
      );
    }

    Pointer<LLVMOpaqueBasicBlock> lastBlock = paramAllocBlock;
    Pointer<LLVMOpaqueBasicBlock> thisBlock;
    for (var statement in this.body) {
      if (statement is TypeDeclaration) {
        continue;
      }
      thisBlock = llvm.LLVMValueAsBasicBlock(statement.generateCode(module));
      if (lastBlock != null) {
        llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
        llvm.LLVMBuildBr(module.builder, thisBlock);
      }
      if (module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(thisBlock)] == null) {
        lastBlock = thisBlock;
      } else {
        lastBlock = llvm.LLVMValueAsBasicBlock(
            module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(thisBlock)]);
      }
    }

    return this.valueRef;
  }
}
