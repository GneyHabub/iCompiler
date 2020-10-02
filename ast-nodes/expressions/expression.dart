import 'comparison.dart';
import 'literal.dart';
import 'operators/not-operator.dart';
import 'operators/and-operator.dart';
import 'operators/or-operator.dart';
import 'operators/xor-operator.dart';
import '../statement.dart';
import '../types/var-type.dart';
import '../../lexer.dart';
import '../../iterator-utils.dart';
import '../../syntax-error.dart';

/// An abstract expression that returns a value.
abstract class Expression implements Statement {
  VarType resultType;
  bool isConstant;

  factory Expression.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    if (!iterator.moveNext()) {
      throw SyntaxError(iterator.current, "Expected expression");
    }

    if (iterator.current.value == 'not') {
      iterator.moveNext();
      return NotOperator(Expression.parse(consumeFull(iterator)));
    } else {
      final firstOperand = Comparison.parse(consumeAwareUntil(
        iterator,
        RegExp('[(\\[]\$'),
        RegExp('[)\\]]\$'),
        RegExp("(xor|or|and)\$"),
      ));
      var operator_ = iterator.current?.value;
      iterator.moveNext();
      Comparison secondOperand = null;
      if (operator_ != null) {
        secondOperand = Expression.parse(consumeFull(iterator));
      }

      switch (operator_) {
        case 'or':
          return OrOperator(firstOperand, secondOperand);
        case 'xor':
          return XorOperator(firstOperand, secondOperand);
        case 'and':
          return AndOperator(firstOperand, secondOperand);
        default:
          return firstOperand;
      }
    }
  }

  /// Return a literal that is equal to the result of this expression.
  ///
  /// Should throw [StateError] for non-constant expressions.
  Literal evaluate();
}
