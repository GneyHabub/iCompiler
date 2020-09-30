import 'modifiable-primary.dart';
import 'var-type.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// A record field access by [name] – for either reading or writing.
///
/// Chained field access requires several [FieldAccess] objects:
/// ```dart
/// // "a.b.c" is represented with
/// FieldAccess("c", FieldAccess("b", Variable("a")))
/// ```
class FieldAccess implements ModifiablePrimary {
  VarType resultType;
  bool isConstant;
  ScopeElement scopeMark;

  String name;
  ModifiablePrimary object;

  FieldAccess(this.name, this.object);

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}FieldAccess("${this.name}")', depth)
      + (this.object?.toString(depth: depth + 1, prefix: 'object: ') ?? '')
    );
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.object.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    // TODO: implement
  }
}
