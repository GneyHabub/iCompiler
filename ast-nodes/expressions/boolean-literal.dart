import 'primary.dart';
import 'boolean-type.dart';
import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// A literal boolean value in code.
class BooleanLiteral implements Primary {
  VarType resultType = BooleanType();
  bool isConstant = true;
  ScopeElement scopeMark;

  bool value;

  BooleanLiteral(this.value);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}BooleanLiteral(${this.value})', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    // TODO: implement
  }
}
