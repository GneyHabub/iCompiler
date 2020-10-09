import '../index.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';

/// The built-in integer type.
class IntegerType implements VarType {
  ScopeElement scopeMark;

  IntegerType();

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}IntegerType', depth);
  }

  @override
  bool operator ==(Object other) {
    if (other is NamedType) {
      return (other.scopeMark.resolve(other.name) as TypeDeclaration).value
          is IntegerType;
    }

    return other is IntegerType;
  }

  @override
  int get hashCode {
    return 0;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}

  VarType resolve() {
    return this;
  }
}
