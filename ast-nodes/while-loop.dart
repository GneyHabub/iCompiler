import 'statement.dart';
import 'expression.dart';

/// A `while` loop.
class WhileLoop implements Statement {
  Expression condition;
  List<Statement> body;

  WhileLoop(this.condition, this.body);

  // TODO: implement .parse()
}
