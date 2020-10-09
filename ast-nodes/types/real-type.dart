import 'var-type.dart';
import 'named-type.dart';
import '../type-declaration.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope-element.dart';

/// The built-in real type.
class RealType implements VarType {
  ScopeElement scopeMark;

  RealType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}RealType', depth);
  }

  @override
  bool operator ==(Object other) {
    if (other is NamedType) {
      return (other.scopeMark.resolve(other.name) as TypeDeclaration).value
          is RealType;
    }

    return other is RealType;
  }

  @override
  int get hashCode {
    return 1;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}

  VarType resolve() {
    return this;
  }
}
