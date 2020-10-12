import 'scope-declaration.dart';
import 'scope-start.dart';
import '../errors/semantic-error.dart';
import '../ast-nodes/index.dart';

/// An abstract element in the scope's linked list (scope chain).
abstract class ScopeElement {
  ScopeElement next;
  
  bool readOnly = false;

  /// Ensure that no other declaration in the chain has the same [name].
  void ensureNoOther(String name) {
    var item = this;
    while (item is! ScopeStart) {
      if (item is ScopeDeclaration && item.declaration.name == name) {
        throw SemanticError(item.declaration,
            "Another object is declared with the name '$name'");
      }
      item = item.next;
    }
  }

  Declaration resolve(String name) {
    ScopeElement item = this;
    while (item != null) {
      if (item is ScopeDeclaration && item.declaration.name == name) {
        return item.declaration;
      } else if (item is ScopeStart) {
        item = (item as ScopeStart).parent;
      }
      item = item.next;
    }

    return null;
  }

  Declaration getNearestRoutine() {
    ScopeElement item = this;
    while (item != null) {
      if (item is ScopeDeclaration && item.declaration is RoutineDeclaration) {
        return item.declaration;
      } else if (item is ScopeStart) {
        item = (item as ScopeStart).parent;
      }
      item = item.next;
    }

    return null;
  }

  String toString({int depth = 0});
}
