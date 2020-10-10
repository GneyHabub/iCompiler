import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../codegen/index.dart';

/// Numeric subtraction operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class SubOperator extends BinaryRelation implements Sum {
  VarType resultType;
  bool isConstant;

  SubOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return RealLiteral(leftLiteral.realValue - rightLiteral.realValue);
    } else {
      return IntegerLiteral(
          leftLiteral.integerValue - rightLiteral.integerValue);
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

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
