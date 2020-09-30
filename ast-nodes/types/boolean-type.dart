import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// The built-in boolean type.
class BooleanType implements VarType {
  ScopeElement scopeMark;

  BooleanType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}BooleanType', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}
}
