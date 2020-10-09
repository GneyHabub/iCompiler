import '../../index.dart';
import '../../../utils/index.dart';
import '../../../symbol-table/index.dart';

/// An abstract unary relation with one [operand].
abstract class UnaryRelation implements Expression {
  ScopeElement scopeMark;

  Expression operand;

  UnaryRelation(this.operand);

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth(prefix + this.runtimeType.toString(), depth) +
        (this.operand?.toString(depth: depth + 1) ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.operand.propagateScopeMark(parentMark);
  }
}
