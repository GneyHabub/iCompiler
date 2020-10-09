import '../ast-nodes/node.dart';

/// A semantic error in the AST.
///
/// Uses the [faultyNode] to give a helpful error message.
class SemanticError implements Exception {
  String cause;
  Node faultyNode;

  SemanticError(this.faultyNode, this.cause);

  String toString() {
    return this.cause;
  }
}
