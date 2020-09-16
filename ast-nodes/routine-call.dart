import '../iterator-utils.dart';
import '../lexer.dart';
import '../parser-utils.dart';
import '../syntax-error.dart';
import 'primary.dart';
import 'expression.dart';
import '../print-utils.dart';

/// A routine call by [name], passing zero or more [arguments].
class RoutineCall implements Primary {
  String name;
  List<Expression> arguments;

  RoutineCall(this.name, this.arguments);

  factory RoutineCall.parse(Iterable<Token> tokens) {
    final openingParenthesis = RegExp('\\(\$');
    final closingParenthesis = RegExp('\\)\$');
    final iter = tokens.iterator;
    checkNext(iter, RegExp('[a-zA-Z_]\w*\$'), "Expected identifier");
    final routineName = iter.current.value;
    if (isReserved(routineName)) {
      throw SyntaxError(iter.current, 'The "$routineName" keyword is reserved');
    }

    checkNext(iter, openingParenthesis, 'Expected "("');
    iter.moveNext();
    var argumentTokens = consumeAwareUntil(
      iter,
      openingParenthesis,
      closingParenthesis,
      closingParenthesis,
    );
    checkThis(iter, closingParenthesis, 'Expected ")"');

    var arguments = <Expression>[];
    var commaTrailing = false;
    final argIter = argumentTokens.iterator;
    while (argIter.moveNext()) {
      final tokenBuff = consumeUntil(argIter, RegExp(",\$"));
      if (tokenBuff.isEmpty) {
        if (argIter.current?.value == ',' || arguments.isNotEmpty) {
          throw SyntaxError(argIter.current, 'Expected an argument');
        } else {
          continue;
        }
      } else {
        arguments.add(Expression.parse(tokenBuff));
        commaTrailing = argIter.current?.value == ',';
      }
    }
    if (commaTrailing) {
      throw SyntaxError(argIter.current, 'Expected an argument');
    }

    return RoutineCall(routineName, arguments);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}RoutineCall("${this.name}")', depth) +
        drawDepth('arguments:', depth + 1) +
        this
            .arguments
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }
}
