import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';

/// Universal _not equal to_ operator.
///
/// Requires both operands to be of the same type.
class NeqOperator extends BinaryRelation implements Comparison {
  NeqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  // TODO: implement .parse()
}
