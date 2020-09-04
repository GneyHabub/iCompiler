import 'binary-relation.dart';
import 'expression.dart';

/// Logical OR operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class OrOperator extends BinaryRelation {
  OrOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
