import 'node.dart';
import 'expression.dart';

/// An iteration range for the `for` loop.
class Range implements Node {
  Expression start;
  Expression end;

  Range(this.start, this.end);

  // TODO: implement .parse()
}
