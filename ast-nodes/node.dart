import '../lexer.dart';
import '../syntax-error.dart';

/// An abstract node of the AST.
abstract class Node {
  /// Construct the node from the given [tokens].
  ///
  /// Expected to throw [SyntaxError] on failure.
  Node.parse(Iterable<Token> tokens);
}
