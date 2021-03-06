import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

/// A literal integer number in code.
class IntegerLiteral implements Literal {
  VarType resultType = IntegerType();
  bool isConstant = true;
  ScopeElement scopeMark;

  int value;

  IntegerLiteral(this.value);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}IntegerLiteral(${this.value})', depth);
  }

  Literal evaluate() {
    return this;
  }

  double get realValue {
    return this.value.toDouble();
  }

  int get integerValue {
    return this.value;
  }

  bool get booleanValue {
    if (this.value == 1) {
      return true;
    }
    if (this.value == 0) {
      return false;
    }
    throw StateError("Only 0 or 1 can be converted to boolean");
  }

  @override
  bool operator ==(Object other) {
    if (other is RealLiteral) {
      return this.realValue == other.realValue;
    } else if (other is IntegerLiteral) {
      return this.integerValue == other.integerValue;
    } else if (other is BooleanLiteral) {
      try {
        return this.booleanValue == other.booleanValue;
      } on StateError {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return this.value.hashCode;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return llvm.LLVMConstInt(
      this.resultType.getLlvmType(module),
      this.value,
      1,  // SignExtend: true
    );
  }
}
