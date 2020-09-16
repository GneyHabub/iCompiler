import 'sum.dart';
import 'expression.dart';
import 'mul-operator.dart';
import 'div-operator.dart';
import 'mod-operator.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../syntax-error.dart';

/// An abstract multiplying operator.
abstract class Product implements Sum {
  factory Product.parse(Iterable<Token> tokens) {
    final iterator = tokens.iterator;

    if (!iterator.moveNext()) {
      throw SyntaxError(iterator.current, "Expected expression");
    }

    final firstOperand = Expression.parsePrioritized(consumeAwareUntil(
      iterator,
      RegExp('\\(\$'),
      RegExp('\\)\$'),
      RegExp("[*/%]\$"),
    ));
    var operator_ = iterator.current?.value;
    iterator.moveNext();
    Product secondOperand = null;
    if (operator_ != null) {
      secondOperand = Expression.parse(consumeFull(iterator));
    }

    switch (operator_) {
      case '*':
        return MulOperator(firstOperand, secondOperand);
      case '/':
        return DivOperator(firstOperand, secondOperand);
      case '%':
        return ModOperator(firstOperand, secondOperand);
      default:
        return firstOperand;
    }
  }
}
