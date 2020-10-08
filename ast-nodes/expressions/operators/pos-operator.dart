import 'unary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../integer-literal.dart';
import '../primary.dart';
import '../expression.dart';
import '../../types/var-type.dart';
import '../../types/real-type.dart';
import '../../types/integer-type.dart';
import '../../types/boolean-type.dart';
import '../../../semantic-utils.dart';
import '../../../semantic-error.dart';

/// Numeric unary plus operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class PosOperator extends UnaryRelation implements Primary {
  VarType resultType;
  bool isConstant;

  PosOperator(Expression operand) : super(operand);

  Literal evaluate() {
    var literal = this.operand.evaluate();
    if (literal is RealLiteral) {
      return RealLiteral(literal.realValue);
    } else {
      return IntegerLiteral(literal.integerValue);
    }
  }

  void checkSemantics() {
    operand.checkSemantics();
    if (operand.resultType is BooleanType) {
      operand = ensureType(operand, IntegerType()); // Cast to a numeric type
    } else if (operand.resultType is! IntegerType &&
        operand.resultType is! RealType) {
      throw SemanticError(this, "'+' operator cannot be applied to this type!");
    }
    this.isConstant = this.operand.isConstant;
  }
}
