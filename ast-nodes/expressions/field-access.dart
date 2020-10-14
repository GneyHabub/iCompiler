import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

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
      throw SemanticError(
          this, "Cannot access a field on something that is not a record");
    }

    var fieldDecl = (this.object.resultType as RecordType)
        .scopes[0]
        .lastChild
        .resolve(this.name);
    this.isConstant = false;
    this.resultType = (fieldDecl as VariableDeclaration).type;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    return llvm.LLVMBuildExtractValue(
      module.builder,
      (this.object as Variable).generateCode(module),
      (this.object.resultType as RecordType).fields.indexWhere((el) => el.name == this.name),
      MemoryManager.getCString('field_access'));
  }

  @override
  Pointer<LLVMOpaqueValue> getPointer(Module module) {
    var indices = MemoryManager.getArray(1).cast<Pointer<LLVMOpaqueValue>>();
    indices.elementAt(0).value = llvm.LLVMConstInt(
      this.resultType.getLlvmType(module),
      (this.object.resultType as RecordType).fields.indexWhere((el) => el.name == this.name),
      1,  // SignExtend: true
    );;
    return llvm.LLVMBuildGEP2(
      module.builder,
      this.resultType.getLlvmType(module),
      this.object.generateCode(module),
      indices,
      1,
      MemoryManager.getCString('field_access')
    );
  }
}
