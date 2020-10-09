import 'var-type.dart';
import 'named-type.dart';
import '../type-declaration.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope-element.dart';

/// The built-in boolean type.
class BooleanType implements VarType {
  ScopeElement scopeMark;

  BooleanType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}BooleanType', depth);
  }

  @override
  bool operator ==(Object other) {
    if (other is NamedType) {
      return (other.scopeMark.resolve(other.name) as TypeDeclaration).value
          is BooleanType;
    }

    return other is BooleanType;
  }

  @override
  int get hashCode {
    return 2;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}

  VarType resolve() {
    return this;
  }
}
