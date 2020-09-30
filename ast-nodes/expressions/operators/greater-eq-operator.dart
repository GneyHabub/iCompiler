import 'binary-relation.dart';
import '../comparison.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';

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
