import 'ast-nodes/index.dart';
import 'ast-nodes/type-conversion.dart';
import 'semantic-error.dart';

Expression ensureType(Expression expression, VarType type) {
  var expType = expression.resultType;
  if (expType == type) {
    return expression;
  } else {
    /**
     * Conversion between non-equal types possible only for built-in types
     */
    if (expType is RecordType ||
        expType is ArrayType ||
        expType is NamedType ||
        type is RecordType ||
        type is NamedType ||
        type is ArrayType) {
      throw SemanticError(expression, 'Type conversion is impossible!');
    } else {
      return TypeConversion(expression, type);
    }
  }
}
