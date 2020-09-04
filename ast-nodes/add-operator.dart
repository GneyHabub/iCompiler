import 'sum.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric addition operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class AddOperator extends BinaryRelation implements Sum {
  AddOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
