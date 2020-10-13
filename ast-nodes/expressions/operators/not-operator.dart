import 'dart:ffi';
import '../../index.dart';
import '../../../utils/index.dart';
import '../../../codegen/index.dart';

/// Logical NOT operator.
///
/// Casts the [operand] to `boolean` and returns a `boolean` value.
class NotOperator extends UnaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  NotOperator(Expression operand) : super(operand);

  Literal evaluate() {
    return BooleanLiteral(!this.operand.evaluate().booleanValue);
  }

  void checkSemantics() {
    this.operand.checkSemantics();
    this.operand = ensureType(this.operand, BooleanType());
    this.isConstant = this.operand.isConstant;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return llvm.LLVMConstNot(
      this.operand.generateCode(module)
    );
  }
}
