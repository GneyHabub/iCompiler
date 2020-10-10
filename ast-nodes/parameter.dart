import 'dart:ffi';
import 'index.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../lexer/token.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A routine parameter, characterized by the [name] and the [type].
class Parameter implements Node {
  ScopeElement scopeMark;

  String name;
  VarType type;

  Parameter(this.name, this.type);

  factory Parameter.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    checkNext(iter, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var nameBuffer = iter.current.value;
    if (isReserved(nameBuffer)) {
      throw SyntaxError(iter.current, "The '$nameBuffer' keyword is reserved");
    }
    checkNext(iter, RegExp(':\$'), "Expected ':'");
    iter.moveNext();

    return Parameter(nameBuffer, VarType.parse(consumeFull(iter)));
  }

  VariableDeclaration toDeclaration() {
    return VariableDeclaration(this.name, this.type, null);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Parameter("${this.name}")', depth) +
        (this.type?.toString(depth: depth + 1, prefix: 'type: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.type.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.type.checkSemantics();
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
