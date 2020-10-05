import '../../../semantic-error.dart';
import '../../../syntax-error.dart';
import '../../index.dart';
import 'binary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../integer-literal.dart';
import '../product.dart';
import '../expression.dart';
import '../../types/var-type.dart';
import '../../../semantic-utils.dart';

/// Numeric division operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class DivOperator extends BinaryRelation implements Product {
  VarType resultType;
  bool isConstant;

  DivOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return RealLiteral(leftLiteral.realValue / rightLiteral.realValue);
    } else {
      return IntegerLiteral(
          leftLiteral.integerValue ~/ rightLiteral.integerValue);
    }
  }

  void checkSemantics() {
    leftOperand.checkSemantics();
    rightOperand.checkSemantics();

    if ((leftOperand.resultType is RealType &&
            rightOperand.resultType is IntegerType) ||
        (rightOperand.resultType is RealType &&
            leftOperand.resultType is IntegerType)) {
      leftOperand = ensureType(leftOperand, RealType());
      rightOperand = ensureType(rightOperand, RealType());
      resultType = RealType();
      isConstant = leftOperand.isConstant && rightOperand.isConstant;
    } else if (leftOperand.resultType is IntegerType &&
        rightOperand.resultType is IntegerType) {
      resultType = IntegerType();
      isConstant = leftOperand.isConstant && rightOperand.isConstant;
    } else {
      throw SemanticError(this,
          'An object of type ${leftOperand.resultType.runtimeType} cannot be divided by an object of type ${rightOperand.resultType.runtimeType}');
    }
  }
}
