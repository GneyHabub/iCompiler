import 'unary-relation.dart';
import '../expression.dart';
import '../../types/boolean-type.dart';
import '../../types/var-type.dart';

/// Logical NOT operator.
///
/// Casts the [operand] to `boolean` and returns a `boolean` value.
class NotOperator extends UnaryRelation {
  VarType resultType = BooleanType();
  bool isConstant;

  NotOperator(Expression operand) : super(operand);

  void checkSemantics() {
    // TODO: implement
  }
}
