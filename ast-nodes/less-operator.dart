import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric _less than_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class LessOperator extends BinaryRelation implements Comparison {
  LessOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
