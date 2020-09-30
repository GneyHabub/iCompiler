import 'sum.dart';
import 'binary-relation.dart';
import 'expression.dart';
import 'var-type.dart';

/// Numeric addition operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class AddOperator extends BinaryRelation implements Sum {
  VarType resultType;
  bool isConstant;

  AddOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
