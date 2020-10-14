import 'dart:ffi';
import '../index.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

/// An array element access by [index] – for either reading or writing.
///
/// Chained element access requires several [IndexAccess] objects:
/// ```dart
/// // "a[0][1]" is represented with
/// IndexAccess(
///   IntegerLiteral(1),
///   IndexAccess(
///     IntegerLiteral(0),
///     Variable("a"),
///   ),
/// )
/// ```
class IndexAccess implements ModifiablePrimary {
  VarType resultType;
  bool isConstant = false;
  ScopeElement scopeMark;

  Expression index;
  ModifiablePrimary object;

  IndexAccess(this.index, this.object);

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}IndexAccess', depth) +
        (this.index?.toString(depth: depth + 1, prefix: 'index: ') ?? '') +
        (this.object?.toString(depth: depth + 1, prefix: 'object: ') ?? ''));
  }

  Literal evaluate() {
    throw StateError("Can't evaluate a non-constant expression");
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.index.propagateScopeMark(parentMark);
    this.object.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.object.checkSemantics();
    this.index.checkSemantics();
    this.index = ensureType(this.index, IntegerType());

    if (this.object.resultType is! ArrayType) {
      throw SemanticError(this, "Only arrays can be indexed");
    }

    this.resultType = (this.object.resultType as ArrayType).elementType;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    var indices = MemoryManager.getArray(2).cast<Pointer<LLVMOpaqueValue>>();
    indices.elementAt(0).value = llvm.LLVMConstInt(
      IntegerType().getLlvmType(module),
      0,
      1,
    );
    indices.elementAt(1).value = this.index.generateCode(module);
    return llvm.LLVMBuildLoad2(
        module.builder,
        resultType.getLlvmType(module),
        llvm.LLVMBuildInBoundsGEP2(
          module.builder,
          this.object.resultType.getLlvmType(module),
          this.object.getPointer(module),
          indices,
          2,
          MemoryManager.getCString('index_access')
        ),
        MemoryManager.getCString('load_array'));
  }

  @override
  Pointer<LLVMOpaqueValue> getPointer(Module module) {
    var indices = MemoryManager.getArray(2).cast<Pointer<LLVMOpaqueValue>>();
    indices.elementAt(0).value = llvm.LLVMConstInt(
      IntegerType().getLlvmType(module),
      0,
      1,
    );
    indices.elementAt(1).value = this.index.generateCode(module);
    return llvm.LLVMBuildInBoundsGEP2(
      module.builder,
      this.object.resultType.getLlvmType(module),
      // this.object.generateCode(module),
      this.object.getPointer(module),
      indices,
      2,
      MemoryManager.getCString('index_access')
    );
  }
}
