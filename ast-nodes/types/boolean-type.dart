import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

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

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }

  Pointer<LLVMOpaqueType> getLlvmType(Module module) {
    return llvm.LLVMInt1TypeInContext(module.context);
  }
}
