import 'statement.dart';
import 'expression.dart';
import '../print-utils.dart';

/// A conditional statement.
class IfStatement implements Statement {
  Expression condition;
  List<Statement> blockTrue;
  List<Statement> blockFalse;

  IfStatement(this.condition, this.blockTrue, this.blockFalse);

  factory IfStatement.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('if\$'), "Expected 'if'");
    var expressionBody = consumeUntil(iterator, RegExp("^then\$"));
    checkThis(iterator, RegExp('then\$'), "Expected 'then'");
    var trueBody = consumeUntil(iterator, RegExp("^(else|end)\$"));
    List<Token> falseBody = null;

    if (iterator.current?.value == "else") {

      falseBody = consumeUntil(iterator, RegExp("^end\$"));
      checkThis(iterator, RegExp('end\$'), "Expected 'end'");
      checkNoMore(iterator);
    } else if (iterator.current?.value == "end") {
      checkNoMore(iterator);
    }

    if (expressionBody.isEmpty) {
      throw SyntaxError(iterator.current, "Expected a condition");
    }

    if (trueBody.isEmpty) {
      throw SyntaxError(iterator.current, "Expected a true statement");
    }

    var expBody = Expression.parse(expressionBody);

    var trueIterator = trueBody.iterator;
    var trueBlock = <Statement>[];
    while (trueIterator.moveNext()) {
      var blockTokens = consumeUntil(trueIterator, RegExp("[\n;]\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      trueBlock.add(Statement.parse(blockTokens));
    }
    

    var falseBlock = <Statement>[];
    if (falseBody != null) {
    var falseIterator = falseBody.iterator;
    while (falseIterator.moveNext()) {
      var blockTokens = consumeUntil(falseIterator, RegExp("[\n;]\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      
      falseBlock.add(Statement.parse(blockTokens));
    }
    }

    return IfStatement(expBody, trueBlock, falseBlock);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}IfStatement', depth)
      + (this.condition?.toString(depth: depth + 1, prefix: 'condition: ') ?? '')
      + drawDepth('true block:', depth + 1)
      + this.blockTrue.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
      + drawDepth('false block:', depth + 1)
      + this.blockFalse.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
    );
  }
}
