import 'binary-relation.dart';
import '../literal.dart';
import '../boolean-literal.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';
import '../../../semantic-utils.dart';

/// Logical XOR operator.
///
/// Casts both operands to `boolean` and returns a `boolean` value.
class XorOperator extends BinaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  XorOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    Literal leftLiteral = this.leftOperand.evaluate();
    Literal rightLiteral = this.rightOperand.evaluate();
    return BooleanLiteral(leftLiteral.booleanValue ^ rightLiteral.booleanValue);
  }

  void checkSemantics() {
    this.leftOperand.checkSemantics();
    this.rightOperand.checkSemantics();

    this.leftOperand = ensureType(this.leftOperand, BooleanType());
    this.rightOperand = ensureType(this.rightOperand, BooleanType());
    this.resultType = BooleanType();
    this.isConstant = (this.leftOperand.isConstant && this.rightOperand.isConstant);
  }
}
