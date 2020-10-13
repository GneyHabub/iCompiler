import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../errors/index.dart';
import '../../../codegen/index.dart';

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

    if (this.leftOperand.resultType is RealType ||
        this.rightOperand.resultType is RealType) {
      this.leftOperand = ensureType(this.leftOperand, RealType());
      this.rightOperand = ensureType(this.rightOperand, RealType());
    } else if (this.leftOperand.resultType is IntegerType ||
        this.rightOperand.resultType is IntegerType) {
      this.leftOperand = ensureType(this.leftOperand, IntegerType());
      this.rightOperand = ensureType(this.rightOperand, IntegerType());
    } else {
      throw SemanticError(this, "Types of the operands are not comparable");
    }

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.resultType is IntegerType) {
      return llvm.LLVMConstICmp(
        8, 
        this.leftOperand.generateCode(module), 
        this.rightOperand.generateCode(module)
      );
    } else {
      return llvm.LLVMConstFCmp(
        4, 
        this.leftOperand.generateCode(module), 
        this.rightOperand.generateCode(module)
      );
    }
  }
}
