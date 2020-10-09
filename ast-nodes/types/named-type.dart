import 'var-type.dart';
import '../type-declaration.dart';
import '../../print-utils.dart';
import '../../semantic-error.dart';
import '../../symbol-table/scope-element.dart';

/// A type that was specified by the [name].
///
/// Refers to custom types declared with [TypeDeclaration]s.
class NamedType implements VarType {
  ScopeElement scopeMark;

  String name;

  NamedType(this.name);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}NamedType("${this.name}")', depth);
  }

  @override
  bool operator ==(Object other) {
    return (this.scopeMark.resolve(this.name) as TypeDeclaration).value ==
        other;
  }

  @override
  int get hashCode {
    return (this.scopeMark.resolve(this.name) as TypeDeclaration)
        .value
        .hashCode;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    var declaration = this.scopeMark.resolve(this.name);
    if (declaration == null) {
      throw SemanticError(this, "'$name' is not defined");
    } else if (declaration is! TypeDeclaration) {
      throw SemanticError(this, "'$name' is not a valid type in this scope");
    }
  }

  VarType resolve() {
    return (this.scopeMark.resolve(this.name) as TypeDeclaration).value;
  }
}
