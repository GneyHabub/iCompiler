import '../iterator-utils.dart';
import '../syntax-error.dart';
import 'node.dart';
import '../lexer.dart';
import 'type-declaration.dart';
import 'variable-declaration.dart';
import 'while-loop.dart';
import 'for-loop.dart';
import 'if-statement.dart';
import 'routine-call.dart';
import 'assignment.dart';

/// An abstract statement.
abstract class Statement implements Node {
  factory Statement.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    if (!iter.moveNext()) {
      throw SyntaxError(tokens.first, 'Expected a statement');
    }

    if (iter.current.value == 'while') {
      return WhileLoop.parse(tokens);
    } else if (iter.current.value == 'for') {
      return ForLoop.parse(tokens);
    } else if (iter.current.value == 'if') {
      return IfStatement.parse(tokens);
    } else if (iter.current.value == 'var') {
      return VariableDeclaration.parse(tokens);
    } else if (iter.current.value == 'type') {
      return TypeDeclaration.parse(tokens);
    }
    iter.moveNext();
    if (iter.current.value == '(') {
      return RoutineCall.parse(tokens);
    }
    var identifierBuffer = consumeUntil(iter, RegExp(':=\$'));
    if (iter.current?.value == ':=') {
      return Assignment.parse(tokens);
    } else {
      throw SyntaxError(tokens.first, 'Expected a statement');
    }
  }
}
