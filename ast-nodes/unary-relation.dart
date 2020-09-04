import 'expression.dart';

/// An abstract unary relation with one [operand].
abstract class UnaryRelation implements Expression {
  Expression operand;

  UnaryRelation(this.operand);
}
