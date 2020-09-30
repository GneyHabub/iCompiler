import 'comparison.dart';
import 'binary-relation.dart';
import 'expression.dart';
import 'boolean-type.dart';
import 'var-type.dart';

/// Universal _not equal to_ operator.
///
/// Requires both operands to be of the same type.
class NeqOperator extends BinaryRelation implements Comparison {
  VarType resultType = BooleanType();
  bool isConstant;

  NeqOperator(Expression leftOperand, Expression rightOperand)
    : super(leftOperand, rightOperand);

  void checkSemantics() {
    // TODO: implement
  }
}
