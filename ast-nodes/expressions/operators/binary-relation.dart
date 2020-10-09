import '../index.dart';
import '../../../utils/index.dart';
import '../../../symbol-table/index.dart';

/// An abstract binary relation with two operands.
abstract class BinaryRelation implements Expression {
  ScopeElement scopeMark;

  Expression leftOperand;
  Expression rightOperand;

  BinaryRelation(this.leftOperand, this.rightOperand);

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth(prefix + this.runtimeType.toString(), depth) +
        (this
                .leftOperand
                ?.toString(depth: depth + 1, prefix: 'left operand: ') ??
            '') +
        (this
                .rightOperand
                ?.toString(depth: depth + 1, prefix: 'right operand: ') ??
            ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.leftOperand.propagateScopeMark(parentMark);
    this.rightOperand.propagateScopeMark(parentMark);
  }
}
