import 'statement.dart';
import 'expressions/expression.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';
import '../symbol-table/scope-element.dart';

/// A return statement in a function.
class ReturnStatement implements Statement {
  ScopeElement scopeMark;

  Expression value;

  ReturnStatement(this.value);

  factory ReturnStatement.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('return\$'), "Expected 'return'");
    if (!iterator.moveNext()) {
      return ReturnStatement(null);
    }
    return ReturnStatement(Expression.parse(consumeFull(iterator)));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}ReturnStatement', depth) +
        (this.value?.toString(depth: depth + 1, prefix: 'value: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.value?.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.value.checkSemantics();
  }
}
