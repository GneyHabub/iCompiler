import 'statement.dart';
import 'variable.dart';
import 'range.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../syntax-error.dart';
import '../lexer.dart';

/// A `for` loop.
class ForLoop implements Statement {
  Variable loopVariable;
  Range range;
  List<Statement> body;

  ForLoop(this.loopVariable, this.range, this.body);

  factory ForLoop.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('for\$'), "Expected 'for'");
    checkNext(iterator, RegExp('[a-zA-Z_]\w*\$'), "Expected identifier");
    var loopVariable = Variable(iterator.current.value);
    checkNext(iterator, RegExp('in\$'), "Expected 'in'");
    iterator.moveNext();
    var range = Range.parse(consumeUntil(iterator, RegExp('loop\$')));
    checkThis(iterator, RegExp('loop\$'), "Expected 'loop'");
    var bodyTokens = consumeUntil(iterator, RegExp('end'));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var bodyIterator = bodyTokens.iterator;
    var statements = <Statement>[];
    while (bodyIterator.moveNext()) {
      var statementTokens = consumeUntil(bodyIterator, RegExp("[\n;]\$"));
      if (statementTokens.isEmpty) {
        continue;
      }

      statements.add(Statement.parse(statementTokens));
    }

    if (statements.isEmpty) {
      throw SyntaxError(iterator.current, 'Expected at least one statement in a loop body');
    }

    return ForLoop(loopVariable, range, statements);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('ForLoop', depth)
      + (this.loopVariable?.toString(depth: depth + 1, prefix: 'loop variable: ') ?? '')
      + (this.range?.toString(depth: depth + 1, prefix: 'range: ') ?? '')
      + drawDepth('body:', depth + 1)
      + this.body.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
    );
  }
}
