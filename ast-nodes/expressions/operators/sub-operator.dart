import '../sum.dart';
import 'binary-relation.dart';
import '../expression.dart';
import '../../types/var-type.dart';

/// Numeric subtraction operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class SubOperator extends BinaryRelation implements Sum {
  VarType resultType;
  bool isConstant;

  SubOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
