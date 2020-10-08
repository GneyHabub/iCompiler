import 'binary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../boolean-literal.dart';
import '../comparison.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/real-type.dart';
import '../../types/integer-type.dart';
import '../../types/var-type.dart';
import '../../../semantic-utils.dart';
import '../../../semantic-error.dart';

/// Numeric _greater than or equal to_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class GreaterEqOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  GreaterEqOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return BooleanLiteral(leftLiteral.realValue >= rightLiteral.realValue);
    } else {
      return BooleanLiteral(
          leftLiteral.integerValue >= rightLiteral.integerValue);
    }
  }

  void checkSemantics() {
    this.leftOperand.checkSemantics();
    this.rightOperand.checkSemantics();

    if (this.leftOperand.resultType is RealType || this.rightOperand.resultType is RealType) {
      this.leftOperand = ensureType(this.leftOperand, RealType());
      this.rightOperand = ensureType(this.rightOperand, RealType());
    }
    else if (leftType is IntegerType || rightType is IntegerType) {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
    } 
    else {
      throw SemanticError(this, "Types of the operands are not comparable");
    }

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }
}