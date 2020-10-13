import 'dart:ffi';
import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A `while` loop.
class WhileLoop implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Expression condition;
  List<Statement> body;

  WhileLoop(this.condition, this.body);

  factory WhileLoop.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    checkNext(iter, RegExp('while\$'), "Expected 'while'");
    iter.moveNext();
    var loopCondition = consumeUntil(iter, RegExp('loop\$'));

    if (loopCondition.isEmpty) {
      throw SyntaxError(iter.current, "Expected a condition");
    }

    checkThis(iter, RegExp('loop\$'), "Expected 'loop'");
    iter.moveNext();
    var loopBody = consumeUntil(iter, RegExp('end\$'));

    if (loopBody.isEmpty) {
      throw SyntaxError(
          iter.current, 'Expected at least one statement in a loop body');
    }

    checkThis(iter, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iter);

    var statements = Statement.parseBody(loopBody);

    return WhileLoop(Expression.parse(loopCondition), statements);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}WhileLoop', depth) +
        (this.condition?.toString(depth: depth + 1, prefix: 'condition: ') ??
            '') +
        drawDepth('body:', depth + 1) +
        this
            .body
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.condition.propagateScopeMark(parentMark);

    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.lastChild;

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
    this.condition.checkSemantics();
    this.condition = ensureType(this.condition, BooleanType());
    for (var statement in this.body) {
      statement.checkSemantics();
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    var currentRoutine = module.getLastRoutine();
    var conditionValue = condition.generateCode(module);

    Pointer<LLVMOpaqueValue> whileCond = llvm.LLVMBuildICmp(
      module.builder,
      LLVMIntPredicate.LLVMIntNE,
      conditionValue,
      llvm.LLVMConstInt(
        IntegerType().getLlvmType(module),
        0,
        0,      // SignExtend: false
      ),
      MemoryManager.getCString('whilecond')
    );


    var whileBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context, 
      currentRoutine, 
      MemoryManager.getCString('while')
    );

    var doBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context, 
      currentRoutine, 
      MemoryManager.getCString('do')
    );

    var endBlock = llvm.LLVMAppendBasicBlockInContext(
      module.context, 
      currentRoutine, 
      MemoryManager.getCString('end')
    );

    llvm.LLVMPositionBuilderAtEnd(module.builder, whileBlock);

    llvm.LLVMBuildCondBr(
      module.builder,
      whileCond,
      doBlock,
      endBlock
    );

    Pointer<LLVMOpaqueBasicBlock> lastBlock = doBlock;
    Pointer<LLVMOpaqueBasicBlock> thisBlock;
    for (var statement in this.body) {
      thisBlock = llvm.LLVMValueAsBasicBlock(statement.generateCode(module));
      if (lastBlock != null) {
        llvm.LLVMPositionBuilderAtEnd(module.builder, lastBlock);
        if (statement is ReturnStatement) {
          llvm.LLVMBuildBr(module.builder, thisBlock);
          llvm.LLVMPositionBuilderAtEnd(module.builder, thisBlock);
          statement.value != null
              ? llvm.LLVMBuildRet(
                  module.builder, statement.value.generateCode(module))
              : llvm.LLVMBuildRetVoid(module.builder);
        } else {
          llvm.LLVMBuildBr(module.builder, thisBlock);
        }
      }
      lastBlock = thisBlock;
    }
    llvm.LLVMBuildBr(module.builder, whileBlock);
    doBlock = llvm.LLVMGetInsertBlock(module.builder);

    llvm.LLVMPositionBuilderAtEnd(module.builder, endBlock);

    return llvm.LLVMBasicBlockAsValue(endBlock);
  }
}
