import 'binary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../integer-literal.dart';
import '../product.dart';
import '../expression.dart';
import '../../types/var-type.dart';
import '../../../semantic-utils.dart';
import '../../types/real-type.dart';
import '../../types/integer-type.dart';

/// Numeric multiplication operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class MulOperator extends BinaryRelation implements Product {
  VarType resultType;
  bool isConstant;

  MulOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return RealLiteral(leftLiteral.realValue * rightLiteral.realValue);
    } else {
      return IntegerLiteral(
          leftLiteral.integerValue * rightLiteral.integerValue);
    }
  }

  void checkSemantics() {
    this.leftOperand.checkSemantics();
    this.rightOperand.checkSemantics();

    if (this.leftOperand.resultType is RealType ||
        this.rightOperand.resultType is RealType) {
      this.leftOperand = ensureType(this.leftOperand, RealType());
      this.rightOperand = ensureType(this.rightOperand, RealType());
      this.resultType = RealType();
    } else {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
      this.resultType = IntegerType();
    }

    this.isConstant =
        (this.leftOperand.isConstant && this.rightOperand.isConstant);
  }
}
