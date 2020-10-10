import 'dart:ffi';
import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A type declaration gives a name to some type [value].
class TypeDeclaration extends Declaration {
  ScopeElement scopeMark;

  VarType value;

  TypeDeclaration(name, this.value) : super(name);

  factory TypeDeclaration.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('type\$'), "Expected 'type'");
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var name = iterator.current.value;
    if (isReserved(name)) {
      throw SyntaxError(iterator.current, "The '$name' keyword is reserved");
    }
    checkNext(iterator, RegExp('is\$'), "Expected 'is'");
    iterator.moveNext();
    var type = VarType.parse(consumeFull(iterator));

    return TypeDeclaration(name, type);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}TypeDeclaration("${this.name}")', depth) +
        (this.value?.toString(depth: depth + 1) ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.value.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.scopeMark.ensureNoOther(this.name);
    value.checkSemantics();
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
