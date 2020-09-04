import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Numeric _less than or equal to_ operator.
///
/// Casts both operands to a numeric type and returns a boolean value.
class LessEqOperator extends BinaryRelation implements Comparison {
  LessEqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
