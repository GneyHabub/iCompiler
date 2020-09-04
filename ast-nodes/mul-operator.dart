import 'product.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric multiplication operator.
///
/// Casts both operands to a numeric type and returns a numeric value.
class MulOperator extends BinaryRelation implements Product {
  MulOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
