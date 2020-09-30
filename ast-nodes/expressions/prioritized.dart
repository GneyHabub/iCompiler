import 'product.dart';
import 'expression.dart';
import 'var-type.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

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
      iterator,
      RegExp("[(\\[]\$"),
      RegExp("[)\\]]\$"),
      RegExp("\\)\$")
    );
    checkThis(iterator, RegExp('\\)\$'), "Expected ')'");
    checkNoMore(iterator);

    return Prioritized(Expression.parse(expressionBuffer));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}Prioritized', depth)
      + (this.operand?.toString(depth: depth + 1) ?? '')
    );
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.operand.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    // TODO: implement
  }
}
