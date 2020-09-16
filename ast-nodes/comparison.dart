import 'expression.dart';
import 'sum.dart';
import 'less-operator.dart';
import 'less-eq-operator.dart';
import 'greater-operator.dart';
import 'greater-eq-operator.dart';
import 'eq-operator.dart';
import 'neq-operator.dart';
import '../lexer.dart';
import '../iterator-utils.dart';

/// An abstract comparison operator.
abstract class Comparison implements Expression {
  factory Comparison.parse(Iterable<Token> tokens) {
    final iterator = tokens.iterator;
    iterator.moveNext();
    final firstOperand = Sum.parse(consumeAwareUntil(
      iterator,
      RegExp('[(\\[]\$'),
      RegExp('[)\\]]\$'),
      RegExp('([<>]=?|=|\\/=)\$'),
    ));
    var operator_ = iterator.current?.value;
    iterator.moveNext();
    Comparison secondOperand = null;
    if (operator_ != null) {
      secondOperand = Comparison.parse(consumeFull(iterator));
    }

    switch (operator_) {
      case '<':
        return LessOperator(firstOperand, secondOperand);
      case '<=':
        return LessEqOperator(firstOperand, secondOperand);
      case '>':
        return GreaterOperator(firstOperand, secondOperand);
      case '>=':
        return GreaterEqOperator(firstOperand, secondOperand);
      case '=':
        return EqOperator(firstOperand, secondOperand);
      case '/=':
        return NeqOperator(firstOperand, secondOperand);
      default:
        return firstOperand;
    }
  }
}
