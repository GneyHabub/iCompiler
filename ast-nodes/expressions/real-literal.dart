import '../index.dart';
import '../../utils/index.dart';
import '../../symbol-table/index.dart';

/// A literal floating-point number in code.
class RealLiteral implements Literal {
  VarType resultType = RealType();
  bool isConstant = true;
  ScopeElement scopeMark;

  double value;

  RealLiteral(this.value);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}RealLiteral(${this.value})', depth);
  }

  Literal evaluate() {
    return this;
  }

  double get realValue {
    return this.value;
  }

  int get integerValue {
    return this.value.toInt();
  }

  bool get booleanValue {
    if (this.value == 1.0) {
      return true;
    }
    if (this.value == 0.0) {
      return false;
    }
    throw StateError("Only 0 or 1 can be converted to boolean");
  }

  @override
  bool operator ==(Object other) {
    if (other is RealLiteral) {
      return this.realValue == other.realValue;
    } else if (other is IntegerLiteral) {
      return this.integerValue == other.integerValue;
    } else if (other is BooleanLiteral) {
      try {
        return this.booleanValue == other.booleanValue;
      } on StateError {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return this.value.hashCode;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}
}
