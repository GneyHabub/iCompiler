import 'scope-element.dart';
import '../ast-nodes/declaration.dart';
import '../utils/print-utils.dart';

/// An object declaration in some scope.
///
/// Instances of this class are the main objects of scope chains.
class ScopeDeclaration extends ScopeElement {
  Declaration declaration;

  ScopeDeclaration(this.declaration);

  String toString({int depth = 0}) {
    return drawDepth("Declaration '${this.declaration.name}'", depth);
  }
}
