import 'index.dart';
import '../lexer/token.dart';
import '../errors/index.dart';

/// A declaration is a [Statement] that creates a new entity with a [name].
abstract class Declaration implements Statement {
  String name;

  Declaration(this.name);

  factory Declaration.parse(Iterable<Token> tokens) {
    if (tokens.isEmpty) {
      throw SyntaxError(tokens.first, "Expected declaration");
    }

    if (tokens.first.value == 'routine') {
      return RoutineDeclaration.parse(tokens);
    } else {
      return Declaration.parseSimple(tokens);
    }
  }

  factory Declaration.parseSimple(Iterable<Token> tokens) {
    if (tokens.isEmpty) {
      throw SyntaxError(tokens.first, "Expected declaration");
    }

    if (tokens.first.value == 'var') {
      return VariableDeclaration.parse(tokens);
    } else if (tokens.first.value == 'type') {
      return TypeDeclaration.parse(tokens);
    } else {
      throw SyntaxError(tokens.first, "Expected declaration");
    }
  }
}
