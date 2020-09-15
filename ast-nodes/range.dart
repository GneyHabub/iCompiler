import '../syntax-error.dart';
import 'node.dart';
import 'expression.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';

/// An iteration range for the `for` loop.
class Range implements Node {
  Expression start;
  Expression end;

  Range(this.start, this.end);

  factory Range.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    if (!iterator.moveNext()) {
      throw SyntaxError(iterator.current, "Expected '..' in range");
    }

    var expStartBuffer = List<Token>();
    var prevToken = iterator.current;
    while (iterator.moveNext()) {
      if (prevToken.value == "." && iterator.current.value == ".") {
        break;
      } else {
        expStartBuffer.add(prevToken);
        prevToken = iterator.current;
      }
    }

    Expression expStart, expEnd;
    if (iterator.moveNext()) {
      expStart = Expression.parse(expStartBuffer);
      expEnd = Expression.parse(consumeFull(iterator));
    } else {
      throw SyntaxError(iterator.current, "Expected .. Expression");
    }

    return Range(expStart, expEnd);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Range', depth) +
        (this.start?.toString(depth: depth + 1, prefix: 'start: ') ?? '') +
        (this.end?.toString(depth: depth + 1, prefix: 'end: ') ?? ''));
  }
}
