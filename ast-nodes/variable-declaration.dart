import 'dart:ffi';
import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A variable declaration contains a [type] and the initial [value].
///
/// Both of these can be set to [null].
class VariableDeclaration extends Declaration {
  ScopeElement scopeMark;

  VarType type;
  Expression value;

  bool readOnly;

  VariableDeclaration(name, this.type, this.value, {this.readOnly = false}) : super(name);

  factory VariableDeclaration.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    checkNext(iter, RegExp('var\$'), 'Expected "var"');
    checkNext(iter, RegExp('[A-Za-z_]\\w*\$'), 'Expected identifier');
    if (isReserved(iter.current.value)) {
      throw SyntaxError(
          iter.current, 'The "${iter.current.value}" keyword is reserved');
    }
    final name = iter.current.value;
    iter.moveNext();
    VarType type = null;
    Expression initialValue = null;

    if (iter.current?.value == ':') {
      iter.moveNext();
      type = VarType.parse(consumeAwareUntil(
          iter, RegExp('record\$'), RegExp('end\$'), RegExp('is\$')));
      if (iter.current?.value == 'is') {
        iter.moveNext();
        initialValue = Expression.parse(consumeFull(iter));
      }
    } else if (iter.current?.value == 'is') {
      iter.moveNext();
      initialValue = Expression.parse(consumeFull(iter));
    } else {
      throw SyntaxError(iter.current, 'Expected ":" or "is"');
    }

    return VariableDeclaration(name, type, initialValue);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}VariableDeclaration("${this.name}")', depth) +
        (this.type?.toString(depth: depth + 1, prefix: 'type: ') ?? '') +
        (this.value?.toString(depth: depth + 1, prefix: 'value: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.type?.propagateScopeMark(parentMark);
    this.value?.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.scopeMark.ensureNoOther(this.name);
    if (this.value != null) {
      this.value.checkSemantics();
    }

    if (this.type != null) {
      this.type.checkSemantics();
      if (this.value != null) {
        this.value = ensureType(this.value, this.type);
      }
    } else if (this.value != null) {
      this.type = this.value.resultType;
    } else {
      throw SemanticError(this, "Type and value cannot be both null");
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    if (!module.isGlobal) {
      var block = llvm.LLVMAppendBasicBlock(
          module.getLastRoutine(), MemoryManager.getCString('var_declaration'));
      llvm.LLVMPositionBuilderAtEnd(module.builder, block);
      this.valueRef = llvm.LLVMBuildAlloca(
          module.builder,
          this.type.resolve().getLlvmType(module),
          MemoryManager.getCString(this.name));
      if (this.value != null) {
        llvm.LLVMBuildStore(
            module.builder, this.value.generateCode(module), this.valueRef);
      }
      return llvm.LLVMBasicBlockAsValue(block);
    }
    else {
      this.valueRef = module.addGlobalVariable(this.name, this.type, this.value);
      return null;
    }
  }
}
