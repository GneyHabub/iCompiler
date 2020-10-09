import '../../index.dart';
import '../../../utils/index.dart';

/// Logical AND operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class AndOperator extends BinaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  AndOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();
    return BooleanLiteral(
        leftLiteral.booleanValue && rightLiteral.booleanValue);
  }

  void checkSemantics() {
    this.leftOperand.checkSemantics();
    this.rightOperand.checkSemantics();
    this.leftOperand = ensureType(this.leftOperand, BooleanType());
    this.rightOperand = ensureType(this.rightOperand, BooleanType());

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }
}
