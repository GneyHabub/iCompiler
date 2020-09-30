import 'var-type.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope-element.dart';

/// The built-in integer type.
class IntegerType implements VarType {
  ScopeElement scopeMark;

  IntegerType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}IntegerType', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}
}
