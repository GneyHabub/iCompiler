import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric _greater than_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class GreaterOperator extends BinaryRelation implements Comparison {
  GreaterOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
