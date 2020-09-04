import 'product.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric modulo operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class ModOperator extends BinaryRelation implements Product {
  ModOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
