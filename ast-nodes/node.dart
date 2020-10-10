import 'dart:ffi';
import '../lexer/token.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

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

  Pointer<LLVMOpaqueValue> generateCode(Module module);
}
