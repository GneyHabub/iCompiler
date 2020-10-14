import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../codegen/index.dart';

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

    this.isConstant =
        (this.leftOperand.isConstant && this.rightOperand.isConstant);
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return llvm.LLVMBuildXor(
      module.builder,
      this.leftOperand.generateCode(module),
      this.rightOperand.generateCode(module),
      MemoryManager.getCString('exclusive-or'),
    );
  }
}
