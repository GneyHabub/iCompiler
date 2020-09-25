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

/// Consume all of the tokens from the iterator.
List<Token> consumeFull(Iterator<Token> iterator) {
  var tokens = <Token>[];
  do {
    tokens.add(iterator.current);
  } while (iterator.moveNext());

  return tokens;
}

/// Consume tokens from the [iterator] until one of them matches the [terminal], ignoring certain areas.
///
/// The difference with [consumeUntil] is the search for terminals only happens outside of regions
/// defined by [starting] and [ending] tokens.
/// In this way, sequences like parentheses with nesting can be correctly consumed:
/// ```dart
/// consumeStackUntil(iterator, RegExp('\\(\$'), RegExp('\\)\$'),  RegExp('\\)\$'));
/// ```
List<Token> consumeAwareUntil(
    Iterator<Token> iterator, RegExp starting, RegExp ending, RegExp terminal) {
  var tokens = <Token>[];
  var stackCount = 0;

  do {
    if (iterator.current == null) {
      throw SyntaxError(null, "Invalid syntax");
    }
    if (starting.hasMatch(iterator.current.value)) {
      stackCount++;
    } else if (ending.hasMatch(iterator.current.value) && stackCount > 0) {
      stackCount--;
    } else if (terminal.hasMatch(iterator.current.value) && stackCount == 0) {
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

/// Check that the current token in the [iterator] matches the [expected] regex.
///
/// Throws a syntax error with a given [errorMessage] if the check fails.
void checkThis(Iterator<Token> iterator, RegExp expected, String errorMessage) {
  if (iterator.current?.value == null || !expected.hasMatch(iterator.current.value)) {
    throw SyntaxError(iterator.current, errorMessage);
  }
}

/// Check that the [iterator] doesn't have any more tokens.
///
/// Throws a syntax error if the check fails.
void checkNoMore(Iterator<Token> iterator) {
  if (iterator.moveNext()) {
    throw SyntaxError(iterator.current, "Expected no more tokens");
  }
}
