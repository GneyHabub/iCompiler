import 'statement.dart';
import 'variable.dart';
import 'range.dart';

/// A `for` loop.
class ForLoop implements Statement {
  Variable loopVariable;
  Range range;
  List<Statement> body;

  ForLoop(this.loopVariable, this.range, this.body);

  // TODO: implement .parse()
}
