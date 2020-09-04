import 'statement.dart';
import 'expression.dart';

/// A conditional statement.
class IfStatement implements Statement {
  Expression condition;
  List<Statement> blockTrue;
  List<Statement> blockFalse;

  IfStatement(this.condition, this.blockTrue, this.blockFalse);
  
  // TODO: implement .parse()
}
