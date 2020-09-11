import 'statement.dart';
import 'expression.dart';
import '../print-utils.dart';

/// A conditional statement.
class IfStatement implements Statement {
  Expression condition;
  List<Statement> blockTrue;
  List<Statement> blockFalse;

  IfStatement(this.condition, this.blockTrue, this.blockFalse);

  // TODO: implement .parse()

  factory IfStatement.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('if\$'), "Expected 'if'");
    var expressionBody = consumeUntil(iterator, RegExp("^then\$"));
    checkThis(iterator, RegExp('then\$'), "Expected 'then'");
    var body = consumeUntil(iterator, RegExp("^else\$"));
    checkThis(iterator, RegExp('else\$'), "Expected 'else'");
    var elseBody = consumeUntil(iterator, RegExp("^end\$"));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    if (expressionBody.isEmpty) {
      throw SyntaxError(iterator.current, "Expected a condition");
    }

    if (body.isEmpty) {
      throw SyntaxError(iterator.current, "Expected a true statement");
    }

    var expBody = Expression.parse(expressionBody);
    var trueBlock = List<Statement>.parse(body);
    var falseBlock = List<Statement>.parse(elseBody);

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
