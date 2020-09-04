import 'product.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric division operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class DivOperator extends BinaryRelation implements Product {
  DivOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
