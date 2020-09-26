import 'node.dart';
import 'var-type.dart';
import '../print-utils.dart';
import '../parser-utils.dart';
import '../syntax-error.dart';
import '../lexer.dart';
import '../iterator-utils.dart';

/// A routine parameter, characterized by the [name] and the [type].
class Parameter implements Node {
  String name;
  VarType type;

  Parameter(this.name, this.type);

  factory Parameter.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    checkNext(iter, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var nameBuffer = iter.current.value;
    if (isReserved(nameBuffer)) {
      throw SyntaxError(iter.current, "The '$nameBuffer' keyword is reserved");
    }
    checkNext(iter, RegExp(':\$'), "Expected ':'");
    iter.moveNext();

    return Parameter(nameBuffer, VarType.parse(consumeFull(iter)));
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}Parameter("${this.name}")', depth)
      + (this.type?.toString(depth: depth + 1, prefix: 'type: ') ?? '')
    );
  }
}
