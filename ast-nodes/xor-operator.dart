import 'binary-relation.dart';
import 'expression.dart';

/// Logical XOR operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class XorOperator extends BinaryRelation {
  XorOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
