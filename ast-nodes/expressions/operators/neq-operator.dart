import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../errors/index.dart';
import '../../../codegen/index.dart';

/// Universal _not equal to_ operator.
///
/// Requires both operands to be convertible to the same type.
class NeqOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  NeqOperator(Expression leftOperand, Expression rightOperand)
      : super(leftOperand, rightOperand);

  Literal evaluate() {
    var leftLiteral = this.leftOperand.evaluate();
    var rightLiteral = this.rightOperand.evaluate();

    if (leftLiteral is RealLiteral || rightLiteral is RealLiteral) {
      return BooleanLiteral(leftLiteral.realValue != rightLiteral.realValue);
    } else if (leftLiteral is IntegerLiteral ||
        rightLiteral is IntegerLiteral) {
      return BooleanLiteral(
          leftLiteral.integerValue != rightLiteral.integerValue);
    } else {
      return BooleanLiteral(
          leftLiteral.booleanValue != rightLiteral.booleanValue);
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
      if (leftType != rightType) {
        throw SemanticError(this, "Cannot compare objects of different types");
      }
    }

    this.isConstant =
        this.leftOperand.isConstant && this.rightOperand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (this.resultType is IntegerType) {
      return llvm.LLVMConstICmp(
        2, 
        this.leftOperand.generateCode(module), 
        this.rightOperand.generateCode(module)
      );
    } else {
      return llvm.LLVMConstFCmp(
        7, 
        this.leftOperand.generateCode(module), 
        this.rightOperand.generateCode(module)
      );
    }
  }
}
