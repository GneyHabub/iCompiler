import 'lexer.dart';
import 'syntax-error.dart';

/// Consume tokens from the [iterator] until one of them matches the [terminal].
///
/// The terminal itself is not included in the returned list.
List<Token> consumeUntil(Iterator<Token> iterator, RegExp terminal) {
  var tokens = <Token>[];
  do {
    if (terminal.hasMatch(iterator.current.value)) {
      break;
    }
    tokens.add(iterator.current);
  } while (iterator.moveNext());

  return tokens;
}

/// Check that the next token in the [iterator] matches the [expected] regex.
///
/// Throws a syntax error with a given [errorMessage] if the check fails.
void checkNext(Iterator<Token> iterator, RegExp expected, String errorMessage) {
  if (!iterator.moveNext() || !expected.hasMatch(iterator.current.value)) {
    throw SyntaxError(iterator.current, errorMessage);
  }
}

/// Check that the [iterator] doesn't have any more tokens.
///
/// Throws a syntax error if the check fails.
void checkNoMore(Iterator<Token> iterator) {
  if (iterator.moveNext()) {
    throw SyntaxError(iterator.current, "Unexpected token");
  }
}
