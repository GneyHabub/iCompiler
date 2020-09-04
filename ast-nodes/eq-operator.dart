import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Universal _equal to_ operator.
///
/// Requires both operands to be of the same type.
class EqOperator extends BinaryRelation implements Comparison {
  EqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
