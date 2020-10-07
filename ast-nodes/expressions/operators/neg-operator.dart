import 'unary-relation.dart';
import '../literal.dart';
import '../real-literal.dart';
import '../integer-literal.dart';
import '../primary.dart';
import '../expression.dart';
import '../../types/var-type.dart';

/// Numeric negation operator.
///
/// Casts the operand to a numeric type and returns a numeric value.
class NegOperator extends UnaryRelation implements Primary {
  VarType resultType;
  bool isConstant;

  NegOperator(Expression operand) : super(operand);

  Literal evaluate() {
    var literal = this.operand.evaluate();
    if (literal is RealLiteral) {
      return RealLiteral(-literal.realValue);
    } else {
      return IntegerLiteral(-literal.integerValue);
    }
  }

  void checkSemantics() {
    this.operand.checkSemantics();
    if (operand is IntegerType) {
      resultType = IntegerType();
    } else if (operand is RealType) {
      resultType = RealType();
    } else {
      throw SemanticError(this, "Cannot apply operator to object of such type");
    }
    this.isConstant = this.operand.isConstant;
  }
}
