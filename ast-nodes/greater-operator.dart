import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric _greater than or equal to_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class GreaterEqOperator extends BinaryRelation implements Comparison {
  GreaterEqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
