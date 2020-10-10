import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../errors/index.dart';
import '../../../codegen/index.dart';

/// Numeric _less than_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class LessOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  LessOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return BooleanLiteral(leftLiteral.realValue < rightLiteral.realValue);
    } else {
      return BooleanLiteral(
          leftLiteral.integerValue < rightLiteral.integerValue);
    }
  }

  void checkSemantics() {
    leftOperand.checkSemantics();
    rightOperand.checkSemantics();

    if (leftOperand.resultType is RealType ||
        rightOperand.resultType is RealType) {
      this.leftOperand = ensureType(this.leftOperand, RealType());
      this.rightOperand = ensureType(this.rightOperand, RealType());
    } else if (leftOperand.resultType is IntegerType ||
        rightOperand.resultType is IntegerType) {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
    } else {
      throw SemanticError(this, "Objects of these types are incomparable!");
    }

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
