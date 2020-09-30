import 'product.dart';
import 'binary-relation.dart';
import 'expression.dart';
import 'var-type.dart';

/// Numeric division operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class DivOperator extends BinaryRelation implements Product {
  VarType resultType;
  bool isConstant;

  DivOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
