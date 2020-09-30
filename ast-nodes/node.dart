import '../lexer.dart';
import '../syntax-error.dart';
import '../symbol-table/scope-element.dart';

/// An abstract node of the AST.
abstract class Node {
  ScopeElement scopeMark;

  /// Construct the node from the given [tokens].
  ///
  /// Expected to throw [SyntaxError] on failure.
  Node.parse(Iterable<Token> tokens);

  String toString({int depth = 0, String prefix = ''});

  void propagateScopeMark(ScopeElement parentMark);

  void checkSemantics();
}
