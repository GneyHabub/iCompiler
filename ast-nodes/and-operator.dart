import 'binary-relation.dart';
import 'expression.dart';

/// Logical AND operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class AndOperator extends BinaryRelation {
  AndOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
