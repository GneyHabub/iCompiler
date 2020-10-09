import 'scope-element.dart';
import 'scope-declaration.dart';
import 'scope-start.dart';
import '../ast-nodes/declaration.dart';
import '../utils/print-utils.dart';

/// The scope of declaring objects.
///
/// Built using a linked list of [ScopeElement]s (the scope chain).
class Scope extends ScopeElement {
  ScopeElement lastChild;

  Scope() {
    lastChild = ScopeStart(this);
  }

  void add(ScopeElement element) {
    element.next = this.lastChild;
    this.lastChild = element;
  }

  ScopeElement addDeclaration(Declaration declaration) {
    var newElement = ScopeDeclaration(declaration);
    this.add(newElement);
    return newElement;
  }

  void addSubscope(Scope subscope) {
    this.add(subscope);
  }

  String toString({int depth = 0}) {
    var chain = <ScopeElement>[];
    var item = this.lastChild;
    while (item is! ScopeStart) {
      chain.add(item);
      item = item.next;
    }

    return (drawDepth('Scope', depth) +
        chain.reversed.map((node) => node.toString(depth: depth + 1)).join(''));
  }
}
