import 'primary.dart';
import 'unary-relation.dart';
import 'expression.dart';

/// Numeric negation operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class NegOperator extends UnaryRelation implements Primary {
  NegOperator(Expression operand) : super(operand);

  // TODO: implement .parse()
}
