import 'literal.dart';
import 'modifiable-primary.dart';
import '../variable-declaration.dart';
import '../types/var-type.dart';
import '../types/integer-type.dart';
import '../types/record-type.dart';
import '../types/array-type.dart';
import '../../print-utils.dart';
import '../../semantic-error.dart';
import '../../symbol-table/scope-element.dart';

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
    return (drawDepth('${prefix}FieldAccess("${this.name}")', depth) +
        (this.object?.toString(depth: depth + 1, prefix: 'object: ') ?? ''));
  }

  Literal evaluate() {
    if (this.name != 'length' || this.object.resultType is! ArrayType) {
      throw StateError("Can't evaluate a non-constant expression");
    }

    return (this.object.resultType as ArrayType).size.evaluate();
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.object.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.object.checkSemantics();
    if (this.name == 'length' && this.object.resultType is ArrayType) {
      this.isConstant = true;
      this.resultType = IntegerType();
    }

    if (this.object.resultType is! RecordType) {
      throw SemanticError(this, "Cannot access a field on something that is not a record");
    }

    var fieldDecl = (this.object.resultType as RecordType).scopes[0].lastChild.resolve(this.name);
    this.isConstant = false;
    this.resultType = (fieldDecl as VariableDeclaration).type;
  }
}
