import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// The built-in real type.
class RealType implements VarType {
  ScopeElement scopeMark;

  RealType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}RealType', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}
}
