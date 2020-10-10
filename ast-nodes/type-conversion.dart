import 'dart:ffi';
import 'index.dart';
import '../utils/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

class TypeConversion implements Expression {
  Expression expression;
  VarType resultType;
  bool isConstant;
  ScopeElement scopeMark;

  TypeConversion(this.expression, this.resultType)
      : isConstant = expression.isConstant;

  @override
  void checkSemantics() {}

  @override
  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.expression.propagateScopeMark(parentMark);
  }

  @override
  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth(
            '${prefix}TypeConversion(${this.resultType.runtimeType})', depth) +
        (this.expression?.toString(depth: depth + 1, prefix: '') ?? ''));
  }

  @override
  Literal evaluate() {
    return (this.expression.evaluate());
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
