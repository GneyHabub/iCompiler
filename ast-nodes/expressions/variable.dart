import 'modifiable-primary.dart';
import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// A variable reference by [name] – for either reading or writing.
class Variable implements ModifiablePrimary {
  VarType resultType;
  bool isConstant = false;
  ScopeElement scopeMark;

  String name;

  Variable(this.name);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}Variable("${this.name}")', depth);
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    // TODO: implement
  }
}
