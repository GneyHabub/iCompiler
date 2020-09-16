import 'statement.dart';
import 'expression.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';

/// A return statement in a function.
class ReturnStatement implements Statement {
  Expression value;

  ReturnStatement(this.value);

  factory ReturnStatement.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('return\$'), "Expected 'return'");
    return ReturnStatement(Expression.parse(consumeFull(iterator)));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}ReturnStatement', depth)
      + (this.value?.toString(depth: depth + 1, prefix: 'value: ') ?? '')
    );
  }
}
