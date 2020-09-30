import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';
import 'boolean-type.dart';
import 'var-type.dart';

/// Numeric _greater than or equal to_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class GreaterEqOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  GreaterEqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
