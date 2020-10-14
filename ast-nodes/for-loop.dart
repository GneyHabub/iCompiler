import 'dart:ffi';
import 'index.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../lexer/token.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A `for` loop.
class ForLoop implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Variable loopVariable;
  Range range;
  List<Statement> body;
  bool isReversed;

  ForLoop(this.loopVariable, this.range, this.body, this.isReversed);

  factory ForLoop.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('for\$'), "Expected 'for'");
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    if (isReserved(iterator.current.value)) {
      throw SyntaxError(iterator.current,
          "The '${iterator.current.value}' keyword is reserved");
    }
    var loopVariable = Variable(iterator.current.value);
    checkNext(iterator, RegExp('in\$'), "Expected 'in'");
    iterator.moveNext();
    var isReversed = false;
    if (iterator.current.value == 'reverse') {
      isReversed = true;
      iterator.moveNext();
    }
    var range = Range.parse(consumeUntil(iterator, RegExp('loop\$')));
    checkThis(iterator, RegExp('loop\$'), "Expected 'loop'");
    iterator.moveNext();
    var bodyTokens = consumeAwareUntil(
      iterator,
      RegExp('(record|for|while|if)\$'),
      RegExp('end\$'),
      RegExp('end\$'),
    );
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var statements = Statement.parseBody(bodyTokens);
    if (statements.isEmpty) {
      throw SyntaxError(
          iterator.current, 'Expected at least one statement in a loop body');
    }

    return ForLoop(loopVariable, range, statements, isReversed);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('ForLoop', depth) +
        (this
                .loopVariable
                ?.toString(depth: depth + 1, prefix: 'loop variable: ') ??
            '') +
        (this.range?.toString(depth: depth + 1, prefix: 'range: ') ?? '') +
        drawDepth('body:', depth + 1) +
        this
            .body
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.loopVariable.propagateScopeMark(parentMark);
    this.range.propagateScopeMark(parentMark);

    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.addDeclaration(
        VariableDeclaration(this.loopVariable.name, IntegerType(), this.range.start, readOnly: true));

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
    this.range.checkSemantics();
    for (var statement in this.body) {
      statement.checkSemantics();
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    module.isStatement = false;
    var currentRoutine = module.getLastRoutine();
    VariableDeclaration loopVarDecl = this.scopes[0].lastChild.resolve(this.loopVariable.name);
    var initBlock = llvm.LLVMValueAsBasicBlock(loopVarDecl.generateCode(module));

    var condBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('cond')
    );

    var doBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('do')
    );

    var updateBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('update')
    );

    var endBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('end')
    );

    llvm.LLVMPositionBuilderAtEnd(module.builder, initBlock);
    llvm.LLVMBuildBr(module.builder, condBlock);

    llvm.LLVMPositionBuilderAtEnd(module.builder, condBlock);
    var conditionValue = llvm.LLVMBuildICmp(
      module.builder,
      this.isReversed ? LLVMIntPredicate.LLVMIntSGE : LLVMIntPredicate.LLVMIntSLE,
      llvm.LLVMBuildLoad2(
          module.builder,
          IntegerType().getLlvmType(module),
          loopVarDecl.valueRef,
          MemoryManager.getCString('load_loop_var')),
      this.range.end.generateCode(module),
      MemoryManager.getCString('for-loop-cond')
    );

    llvm.LLVMBuildCondBr(
      module.builder,
      conditionValue,
      doBlock,
      endBlock
    );

    Pointer<LLVMOpaqueBasicBlock> lastBlock = doBlock;
    Pointer<LLVMOpaqueBasicBlock> thisBlock;
    for (var statement in this.body) {
      module.isStatement = true;
      thisBlock = llvm.LLVMValueAsBasicBlock(statement.generateCode(module));
      module.isStatement = false;

      llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
      llvm.LLVMBuildBr(module.builder, thisBlock);

      if (module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(thisBlock)] == null) {
        lastBlock = thisBlock;
      } else {
        lastBlock = llvm.LLVMValueAsBasicBlock(
            module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(thisBlock)]);
      }
    }
    llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
    llvm.LLVMBuildBr(module.builder, updateBlock);

    llvm.LLVMPositionBuilderAtEnd(module.builder, updateBlock);
    var updatedLoopVar = llvm.LLVMBuildAdd(
      module.builder,
      llvm.LLVMBuildLoad2(
          module.builder,
          IntegerType().getLlvmType(module),
          loopVarDecl.valueRef,
          MemoryManager.getCString('load_loop_var')),
      llvm.LLVMConstInt(
        IntegerType().getLlvmType(module),
        this.isReversed ? -1 : 1,
        1,  // SignExtend: true
      ),
      MemoryManager.getCString('loop-var-update')
    );
    llvm.LLVMBuildStore(
        module.builder,
        updatedLoopVar,
        loopVarDecl.valueRef);
    llvm.LLVMBuildBr(module.builder, condBlock);

    llvm.LLVMPositionBuilderAtEnd(module.builder, endBlock);

    module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(initBlock)] =
        llvm.LLVMBasicBlockAsValue(endBlock);
    return llvm.LLVMBasicBlockAsValue(initBlock);
  }
}
