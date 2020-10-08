import 'unary-relation.dart';
import '../literal.dart';
import '../boolean-literal.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';
import '../../../semantic-utils.dart';

/// Logical NOT operator.
///
/// Casts the [operand] to `boolean` and returns a `boolean` value.
class NotOperator extends UnaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  NotOperator(Expression operand) : super(operand);

  Literal evaluate() {
    return BooleanLiteral(!this.operand.evaluate().booleanValue);
  }

  void checkSemantics() {
    this.operand.checkSemantics();
    this.operand = ensureType(this.operand, BooleanType());
    this.isConstant = this.operand.isConstant;
  }
}
