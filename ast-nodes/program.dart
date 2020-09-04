import 'node.dart';
import 'declaration.dart';
import 'variable-declaration.dart';
import 'type-declaration.dart';
import 'routine-declaration.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../syntax-error.dart';

/// A program is a list of [Declaration]s.
///
/// Declarations can be of three types:
///  - [VariableDeclaration]s
///  - [TypeDeclaration]s
///  - [RoutineDeclaration]s
class Program implements Node {
  List<Declaration> declarations;

  Program(this.declarations);

  factory Program.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    var declarations = <Declaration>[];

    while (iterator.moveNext()) {
      var declaration = consumeUntil(iterator, RegExp("^[\n;]\$"));
      if (declaration.isEmpty) {
        continue;
      }

      if (declaration[0].value == 'var') {
        declarations.add(VariableDeclaration.parse(declaration));
      } else if (declaration[0].value == 'type') {
        declarations.add(TypeDeclaration.parse(declaration));
      } else if (declaration[0].value == 'routine') {
        declarations.add(RoutineDeclaration.parse(declaration));
      } else {
        throw SyntaxError(declaration[0], "Expected declaration, found $declaration[0]");
      }
    }

    return Program(declarations);
  }
}
