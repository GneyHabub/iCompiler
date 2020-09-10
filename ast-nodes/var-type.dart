import 'node.dart';
import 'integer-type.dart';
import 'real-type.dart';
import 'boolean-type.dart';
import 'array-type.dart';
import 'record-type.dart';
import 'named-type.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../parser-utils.dart';
import '../syntax-error.dart';

/// A type of a variable.
abstract class VarType implements Node {
  factory VarType.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    if (!iterator.moveNext()) {
      throw SyntaxError(null, "Expected a type");
    }

    var primitives = <String, VarType>{
      'integer': IntegerType(),
      'real': RealType(),
      'boolean': BooleanType(),
    };

    if (primitives.containsKey(iterator.current.value)) {
      var result = primitives[iterator.current.value];
      if (iterator.moveNext()) {
        throw SyntaxError(iterator.current, "Unexpected token");
      }
      return result;
    }

    if (iterator.current.value == 'array') {
      return ArrayType.parse(tokens);
    }
    if (iterator.current.value == 'record') {
      return RecordType.parse(tokens);
    }

    if (isReserved(iterator.current.value)) {
      throw SyntaxError(iterator.current, "The '${iterator.current.value}' keyword is reserved");
    }

    var result = NamedType(iterator.current.value);
    checkNoMore(iterator);
    return result;
  }
}
