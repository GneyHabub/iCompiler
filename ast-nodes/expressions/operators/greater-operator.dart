import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../errors/index.dart';
import '../../../codegen/index.dart';

/// Numeric _greater than_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class GreaterOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  GreaterOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return BooleanLiteral(leftLiteral.realValue > rightLiteral.realValue);
    } else {
      return BooleanLiteral(
          leftLiteral.integerValue > rightLiteral.integerValue);
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
    } else if (leftType is IntegerType || rightType is IntegerType) {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
    } else {
      throw SemanticError(this, "Cannot compare objects of such types");
    }

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.leftOperand.resultType is IntegerType) {
      return llvm.LLVMBuildICmp(
        module.builder,
        LLVMIntPredicate.LLVMIntSGT,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('greater-than'),
      );
    } else {
      return llvm.LLVMBuildFCmp(
        module.builder,
        LLVMRealPredicate.LLVMRealOGT,
        this.leftOperand.generateCode(module),
        this.rightOperand.generateCode(module),
        MemoryManager.getCString('greater-than'),
      );
    }
  }
}
