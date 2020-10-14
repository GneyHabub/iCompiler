import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

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

  Literal evaluate() {
    throw StateError("Can't evaluate a non-constant expression");
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    var declaration = this.scopeMark.resolve(this.name);
    if (declaration is! VariableDeclaration) {
      throw SemanticError(this, "Variable ${this.name} is not declared");
    }
    this.resultType = (declaration as VariableDeclaration).type.resolve();
  }

  Pointer<LLVMOpaqueValue> getPointer(Module module) {
    return scopeMark.resolve(name).valueRef;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (true) {
      return llvm.LLVMBuildLoad2(
          module.builder,
          resultType.getLlvmType(module),
          scopeMark.resolve(name).valueRef,
          MemoryManager.getCString('load_${this.name}'));
    }
    else {
      return llvm.LLVMGetNamedGlobal(
          module.module,
          MemoryManager.getCString('load_${this.name}'));
    }
  }
}
