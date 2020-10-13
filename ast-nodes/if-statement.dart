import 'dart:ffi';
import 'index.dart';
import '../utils/index.dart';
import '../lexer/token.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A conditional statement.
class IfStatement implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Expression condition;
  List<Statement> blockTrue;
  List<Statement> blockFalse;

  IfStatement(this.condition, this.blockTrue, this.blockFalse);

  factory IfStatement.parse(Iterable<Token> tokens) {
    final nestedBlockStart = RegExp("(record|for|if|while)\$");
    final nestedBlockEnd = RegExp("end\$");
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('if\$'), "Expected 'if'");
    iterator.moveNext();
    var condition = Expression.parse(consumeUntil(iterator, RegExp("then\$")));
    checkThis(iterator, RegExp('then\$'), "Expected 'then'");
    iterator.moveNext();

    var trueBlock = Statement.parseBody(consumeAwareUntil(
      iterator,
      nestedBlockStart,
      nestedBlockEnd,
      RegExp('(end|else)\$'),
    ));

    if (trueBlock.isEmpty) {
      throw SyntaxError(
          iterator.current, "Expected at least one statement in the block");
    }

    List<Statement> falseBlock = [];
    if (iterator.current?.value == "else") {
      iterator.moveNext();
      falseBlock = Statement.parseBody(consumeAwareUntil(
          iterator, nestedBlockStart, nestedBlockEnd, nestedBlockEnd));

      if (falseBlock.isEmpty) {
        throw SyntaxError(
            iterator.current, "Expected at least one statement in the block");
      }

      checkThis(iterator, nestedBlockEnd, "Expected 'end'");
      checkNoMore(iterator);
    } else if (iterator.current?.value == "end") {
      checkNoMore(iterator);
    } else {
      throw SyntaxError(iterator.current, "Expected 'else' or 'end'");
    }

    return IfStatement(condition, trueBlock, falseBlock);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}IfStatement', depth) +
        (this.condition?.toString(depth: depth + 1, prefix: 'condition: ') ??
            '') +
        drawDepth('true block:', depth + 1) +
        this
            .blockTrue
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join('') +
        drawDepth('false block:', depth + 1) +
        this
            .blockFalse
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.condition.propagateScopeMark(parentMark);

    var scopeTrue = Scope();
    var scopeFalse = Scope();
    this.scopes = [scopeTrue, scopeFalse];
    var bodies = <List<Statement>>[this.blockTrue, this.blockFalse];

    for (var i = 0; i < bodies.length; ++i) {
      ScopeElement currentMark = this.scopes[i].lastChild;
      for (var statement in bodies[i]) {
        statement.propagateScopeMark(currentMark);
        if (statement is Declaration) {
          currentMark = this.scopes[i].addDeclaration(statement);
        }
        if (statement is ScopeCreator) {
          (statement as ScopeCreator)
              .scopes
              .forEach((subscope) => this.scopes[i].addSubscope(subscope));
        }
      }
    }
  }

  void checkSemantics() {
    this.condition.checkSemantics();
    this.condition = ensureType(this.condition, BooleanType());

    for (var statement in this.blockTrue) {
      statement.checkSemantics();
    }
    for (var statement in this.blockFalse) {
      statement.checkSemantics();
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    var currentRoutine = module.getLastRoutine();
    var conditionValue = condition.generateCode(module);

    var ifCond = llvm.LLVMBuildICmp(
      module.builder,
      LLVMIntPredicate.LLVMIntNE,
      conditionValue,
      llvm.LLVMConstInt(
        BooleanType().getLlvmType(module),
        0,
        0,  // SignExtend: false
      ),
      MemoryManager.getCString('ifcond')
    );

    var ifBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('if')
    );

    var thenBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('then')
    );

    var elseBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('else')
    );

    var endBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context,
      currentRoutine,
      MemoryManager.getCString('end')
    );

    llvm.LLVMPositionBuilderAtEnd(module.builder, ifBlock);

    llvm.LLVMBuildCondBr(
      module.builder,
      ifCond,
      thenBlock,
      elseBlock
    );

    Pointer<LLVMOpaqueBasicBlock> lastBlock = thenBlock;
    Pointer<LLVMOpaqueBasicBlock> thisBlock;
    for (var statement in this.blockTrue) {
      thisBlock = llvm.LLVMValueAsBasicBlock(statement.generateCode(module));

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
    llvm.LLVMBuildBr(module.builder, endBlock);

    lastBlock = elseBlock;
    for (var statement in this.blockFalse) {
      thisBlock = llvm.LLVMValueAsBasicBlock(statement.generateCode(module));

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
    llvm.LLVMBuildBr(module.builder, endBlock);
    
    module.LLVMValuesStorage[llvm.LLVMBasicBlockAsValue(ifBlock)] = 
        llvm.LLVMBasicBlockAsValue(endBlock);

    return llvm.LLVMBasicBlockAsValue(ifBlock);
  }
}
