import 'unary-relation.dart';
import 'expression.dart';

/// Logical NOT operator.
///
/// Casts the [operand] to `boolean` and returns a `boolean` value.
class NotOperator extends UnaryRelation {
  NotOperator(Expression operand) : super(operand);

  // TODO: implement .parse()
}
