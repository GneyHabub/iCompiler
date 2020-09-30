import '../product.dart';
import 'binary-relation.dart';
import '../expression.dart';
import '../../types/var-type.dart';

/// Numeric modulo operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class ModOperator extends BinaryRelation implements Product {
  VarType resultType;
  bool isConstant;

  ModOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
