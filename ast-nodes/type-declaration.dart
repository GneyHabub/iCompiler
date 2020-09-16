import 'declaration.dart';
import 'var-type.dart';
import '../lexer.dart';
import '../syntax-error.dart';
import '../iterator-utils.dart';
import '../parser-utils.dart';
import '../print-utils.dart';

/// A type declaration gives a name to some type [value].
class TypeDeclaration extends Declaration {
  VarType value;

  TypeDeclaration(name, this.value) : super(name);

  factory TypeDeclaration.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('type\$'), "Expected 'type'");
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var name = iterator.current.value;
    if (isReserved(name)) {
      throw SyntaxError(iterator.current, "The '${iterator.current.value}' keyword is reserved");
    }
    checkNext(iterator, RegExp('is\$'), "Expected 'is'");
    var type = VarType.parse(consumeFull(iterator));
    checkNoMore(iterator);

    return TypeDeclaration(name, type);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}TypeDeclaration("${this.name}")', depth)
      + (this.value?.toString(depth: depth + 1) ?? '')
    );
  }
}
