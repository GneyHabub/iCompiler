import 'dart:ffi';
import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

/// A prioritized expression.
class Prioritized implements Product {
  VarType resultType;
  bool isConstant;
  ScopeElement scopeMark;

  Expression operand;

  Prioritized(this.operand);

  factory Prioritized.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('\\(\$'), 'Expected parenthesized expression');
    iterator.moveNext();
    final expressionBuffer = consumeAwareUntil(
        iterator, RegExp("[(\\[]\$"), RegExp("[)\\]]\$"), RegExp("\\)\$"));
    checkThis(iterator, RegExp('\\)\$'), "Expected ')'");
    checkNoMore(iterator);

    return Prioritized(Expression.parse(expressionBuffer));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Prioritized', depth) +
        (this.operand?.toString(depth: depth + 1) ?? ''));
  }

  Literal evaluate() {
    return this.operand.evaluate();
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.operand.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.operand.checkSemantics();
    this.resultType = this.operand.resultType;
    this.isConstant = this.operand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return this.operand.generateCode(module);
  }
}
