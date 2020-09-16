import 'product.dart';
import 'expression.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../print-utils.dart';

/// A prioritized expression.
class Prioritized implements Product {
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
}
