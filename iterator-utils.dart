import 'lexer.dart';

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
