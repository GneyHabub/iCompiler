import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../codegen/index.dart';

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

    if (leftOperand.resultType is RealType ||
        rightOperand.resultType is RealType) {
      leftOperand = ensureType(leftOperand, RealType());
      rightOperand = ensureType(rightOperand, RealType());
      resultType = RealType();
      isConstant = leftOperand.isConstant && rightOperand.isConstant;
    } else {
      leftOperand = ensureType(leftOperand, IntegerType());
      rightOperand = ensureType(rightOperand, IntegerType());
      resultType = IntegerType();
      isConstant = leftOperand.isConstant && rightOperand.isConstant;
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.resultType is IntegerType) {
      return llvm.LLVMBuildSDiv(
        module.builder,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('division'),
      );
    } else {
      return llvm.LLVMBuildFDiv(
        module.builder,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('division'),
      );
    }
  }
}
