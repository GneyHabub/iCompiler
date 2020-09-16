import 'primary.dart';
import 'unary-relation.dart';
import 'expression.dart';

/// Numeric unary plus operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class PosOperator extends UnaryRelation implements Primary {
  PosOperator(Expression operand) : super(operand);
}
