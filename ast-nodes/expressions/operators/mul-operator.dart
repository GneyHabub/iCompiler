import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../codegen/index.dart';

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

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.resultType is IntegerType) {
      return llvm.LLVMBuildMul(
        module.builder,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('multiplication'),
      );
    } else {
      return llvm.LLVMBuildFMul(
        module.builder,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('multiplication'),
      );
    }
  }
}
