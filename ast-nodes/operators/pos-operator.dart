import 'primary.dart';
import 'unary-relation.dart';
import 'expression.dart';
import 'var-type.dart';

/// Numeric unary plus operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class PosOperator extends UnaryRelation implements Primary {
  VarType resultType;
  bool isConstant;

  PosOperator(Expression operand) : super(operand);

  void checkSemantics() {
    // TODO: implement
  }
}
