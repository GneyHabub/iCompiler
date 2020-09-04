import 'sum.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric subtraction operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class SubOperator extends BinaryRelation implements Sum {
  SubOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
