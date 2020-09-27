import 'binary-relation.dart';
import 'expression.dart';
import 'boolean-type.dart';
import 'var-type.dart';

/// Logical AND operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class AndOperator extends BinaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  AndOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);
}
