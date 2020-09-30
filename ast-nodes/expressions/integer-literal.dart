import 'primary.dart';
import 'integer-type.dart';
import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// A literal integer number in code.
class IntegerLiteral implements Primary {
  VarType resultType = IntegerType();
  bool isConstant = true;
  ScopeElement scopeMark;

  int value;

  IntegerLiteral(this.value);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}IntegerLiteral(${this.value})', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    // TODO: implement
  }
}
