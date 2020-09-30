import 'binary-relation.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';

/// Logical OR operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class OrOperator extends BinaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  OrOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
