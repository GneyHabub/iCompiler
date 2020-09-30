import 'primary.dart';
import 'unary-relation.dart';
import 'expression.dart';
import 'var-type.dart';

/// Numeric negation operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class NegOperator extends UnaryRelation implements Primary {
  VarType resultType;
  bool isConstant;

  NegOperator(Expression operand) : super(operand);

  void checkSemantics() {
    // TODO: implement
  }
}
