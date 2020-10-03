import '../print-utils.dart';
import '../symbol-table/scope-element.dart';
import 'index.dart';

class TypeConversion implements Expression {
  Expression expression;
  VarType resultType;
  bool isConstant;
  ScopeElement scopeMark;

  TypeConversion(this.expression, this.resultType);

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
            '${prefix}TypeConversion: (${this.resultType.runtimeType})',
            depth) +
        (this.expression?.toString(depth: depth + 1, prefix: '') ?? ''));
  }

  @override
  Literal evaluate() {
    return (this.expression.evaluate());
  }
}