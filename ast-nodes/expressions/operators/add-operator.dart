import 'binary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../integer-literal.dart';
import '../sum.dart';
import '../expression.dart';
import '../../types/var-type.dart';
import '../../types/real-type.dart';
import '../../types/integer-type.dart';
import '../../../semantic-utils.dart';

/// Numeric addition operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class AddOperator extends BinaryRelation implements Sum {
  VarType resultType;
  bool isConstant;

  AddOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return RealLiteral(leftLiteral.realValue + rightLiteral.realValue);
    } else {
      return IntegerLiteral(
          leftLiteral.integerValue + rightLiteral.integerValue);
    }
  }

  void checkSemantics() {
    this.leftOperand.checkSemantics();
    this.rightOperand.checkSemantics();

    var leftType = this.leftOperand.resultType;
    var rightType = this.rightOperand.resultType;

    if (leftType is RealType || rightType is RealType) {
      this.leftOperand = ensureType(this.leftOperand, RealType());
      this.rightOperand = ensureType(this.rightOperand, RealType());
      this.resultType = RealType();
    } else {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
      this.resultType = IntegerType();
    }

    this.isConstant = this.leftOperand.isConstant && this.rightOperand.isConstant;
  }
}
