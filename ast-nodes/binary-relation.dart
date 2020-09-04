import 'expression.dart';

/// An abstract binary relation with two operands.
abstract class BinaryRelation implements Expression {
  Expression leftOperand;
  Expression rightOperand;

  BinaryRelation(this.leftOperand, this.rightOperand);
}
