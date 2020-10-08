import 'declaration.dart';
import 'types/var-type.dart';
import '../lexer.dart';
import '../syntax-error.dart';
import '../iterator-utils.dart';
import '../parser-utils.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';
import '../semantic-error.dart';

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
    value.checkSemantics();

    var declaration = this.scopeMark.resolve(this.name);
    if (declaration is! null) {
      throw SemanticError(this, "Variable or type with name ${this.name} is already declared");
    }
  }
}
