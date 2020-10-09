import 'scope.dart';
import 'scope-element.dart';

/// The initial element in the [Scope] chain, also its terminating element.
///
/// Contains a reference to the [parent] scope to continue traversal.
class ScopeStart extends ScopeElement {
  Scope parent;

  ScopeStart(this.parent);

  String toString({int depth = 0}) {
    return 'Scope start';
  }
}
