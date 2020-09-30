import '../product.dart';
import 'binary-relation.dart';
import '../expression.dart';
import '../../types/var-type.dart';

/// Numeric multiplication operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class MulOperator extends BinaryRelation implements Product {
  VarType resultType;
  bool isConstant;

  MulOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
