import '../comparison.dart';
import 'binary-relation.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';

/// Numeric _less than or equal to_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class LessEqOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  LessEqOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
