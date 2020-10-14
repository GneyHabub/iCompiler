import 'dart:ffi';
import '../../index.dart';
import '../../../errors/index.dart';
import '../../../codegen/index.dart';

/// Numeric negation operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class NegOperator extends UnaryRelation implements Primary {
  VarType resultType;
  bool isConstant;

  NegOperator(Expression operand) : super(operand);

  Literal evaluate() {
    var literal = this.operand.evaluate();
    if (literal is RealLiteral) {
      return RealLiteral(-literal.realValue);
    } else {
      return IntegerLiteral(-literal.integerValue);
    }
  }

  void checkSemantics() {
    this.operand.checkSemantics();
    if (operand.resultType is IntegerType) {
      resultType = IntegerType();
    } else if (operand.resultType is RealType) {
      resultType = RealType();
    } else {
      throw SemanticError(this, "Cannot apply operator to object of such type");
    }
    this.isConstant = this.operand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.resultType is IntegerType) {
      return llvm.LLVMBuildNeg(
        module.builder,
        this.operand.generateCode(module),
        MemoryManager.getCString('negation'),
      );
    } else {
      return llvm.LLVMBuildFNeg(
        module.builder,
        this.operand.generateCode(module),
        MemoryManager.getCString('negation'),
      );
    }
  }
}
