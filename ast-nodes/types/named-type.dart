import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

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
    return this.resolve() == other;
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

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return null;
  }

  Pointer<LLVMOpaqueType> getLlvmType(Module module) {
    return this.resolve().getLlvmType(module);
  }
}
