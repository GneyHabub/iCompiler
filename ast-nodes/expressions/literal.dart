import '../index.dart';
import '../../symbol-table/index.dart';

/// A literal integer number in code.
abstract class Literal implements Primary {
  VarType resultType;
  bool isConstant = true;
  ScopeElement scopeMark;

  double get realValue;

  int get integerValue;

  bool get booleanValue;
}
