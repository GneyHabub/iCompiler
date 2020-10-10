import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

/// A literal boolean value in code.
class BooleanLiteral implements Literal {
  VarType resultType = BooleanType();
  bool isConstant = true;
  ScopeElement scopeMark;

  bool value;

  BooleanLiteral(this.value);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}BooleanLiteral(${this.value})', depth);
  }

  Literal evaluate() {
    return this;
  }

  double get realValue {
    return (this.value ? 1.0 : 0.0);
  }

  int get integerValue {
    return (this.value ? 1 : 0);
  }

  bool get booleanValue {
    return this.value;
  }

  @override
  bool operator ==(Object other) {
    if (other is RealLiteral) {
      return this.realValue == other.realValue;
    } else if (other is IntegerLiteral) {
      return this.integerValue == other.integerValue;
    } else if (other is BooleanLiteral) {
      return this.booleanValue == other.booleanValue;
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
    // TODO: implement
    return null;
  }
}
