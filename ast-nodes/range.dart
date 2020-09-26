import '../syntax-error.dart';
import 'node.dart';
import 'expression.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';
import '../symbol-table/scope-element.dart';

/// An iteration range for the `for` loop.
class Range implements Node {
  ScopeElement scopeMark;

  Expression start;
  Expression end;

  Range(this.start, this.end);

  factory Range.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    if (!iterator.moveNext()) {
      throw SyntaxError(iterator.current, "Expected range");
    }

    var expStart = Expression.parse(consumeUntil(iterator, RegExp('\\.\\.\$')));
    checkThis(iterator, RegExp('\\.\\.\$'), "Expected '..'");
    iterator.moveNext();
    var expEnd = Expression.parse(consumeFull(iterator));

    return Range(expStart, expEnd);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Range', depth) +
        (this.start?.toString(depth: depth + 1, prefix: 'start: ') ?? '') +
        (this.end?.toString(depth: depth + 1, prefix: 'end: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.start.propagateScopeMark(parentMark);
    this.end.propagateScopeMark(parentMark);
  }
}
