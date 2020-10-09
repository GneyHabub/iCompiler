import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';

/// An abstract multiplying operator.
abstract class Product implements Sum {
  factory Product.parse(Iterable<Token> tokens) {
    final iterator = tokens.iterator;

    if (!iterator.moveNext()) {
      throw SyntaxError(iterator.current, "Expected expression");
    }

    final firstOperandTokens = consumeAwareUntil(
      iterator,
      RegExp('[(\\[]\$'),
      RegExp('[)\\]]\$'),
      RegExp("[*/%]\$"),
    );

    Product firstOperand = null;
    if (firstOperandTokens.first.value == '(') {
      firstOperand = Prioritized.parse(firstOperandTokens);
    } else {
      firstOperand = Primary.parse(firstOperandTokens);
    }
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
