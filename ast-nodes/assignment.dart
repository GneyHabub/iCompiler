import 'statement.dart';
import 'expressions/modifiable-primary.dart';
import 'expressions/expression.dart';
import '../print-utils.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../syntax-error.dart';
import '../symbol-table/scope-element.dart';

/// An assignment of the value on the right hand side ([rhs]) to the left hand side ([lhs]).
class Assignment implements Statement {
  ScopeElement scopeMark;

  ModifiablePrimary lhs;
  Expression rhs;

  Assignment(this.lhs, this.rhs);

  factory Assignment.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;

    if (!iter.moveNext()) {
      throw SyntaxError(iter.current, "Expected an assignment");
    }

    var lhs = ModifiablePrimary.parse(consumeUntil(iter, RegExp(":=\$")));
    checkThis(iter, RegExp(':=\$'), 'Expected ":="');
    iter.moveNext();
    return Assignment(lhs, Expression.parse(consumeFull(iter)));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Assignment', depth) +
        (this.lhs?.toString(depth: depth + 1, prefix: 'lhs: ') ?? '') +
        (this.rhs?.toString(depth: depth + 1, prefix: 'rhs: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.lhs.propagateScopeMark(parentMark);
    this.rhs.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    // TODO: implement
  }
}
