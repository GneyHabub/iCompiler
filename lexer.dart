/// A lexer token.
///
/// It isn't a fully formed language token.
/// Combining the tokens will happen during syntax analysis.
class Token {
  final String value;
  final int start;
  final int end;

  String toString() {
    return 'Token "${value == '\n' ? '\\n' : value}", ${start}–${end}';
  }

  const Token(this.value, this.start, this.end);
}

RegExp langTokenPtn = RegExp(
  '(' +
      '[a-zA-Z_]\\w*' +
      '|' // identifiers
      +
      '[0-9]+(?:\\.[0-9]*)?' +
      '|' // numeric literals
      +
      ':=|<=|>=|\\/=|\\.\\.' +
      '|' // compound operators
      +
      '[;\n:\\[\\](),<>=*\\/%+-.]'
      // miscellaneous symbols
      +
      ')',
  multiLine: true,
);
RegExp allWhitespacePtn = RegExp("^\\s+\$");

/// The main lexer function, splits the source code into lexer [Token]s.
Iterable<Token> splitToTokens(String sourceCode) sync* {
  RegExpMatch previousMatch = null;
  for (var match in langTokenPtn.allMatches(sourceCode)) {
    if (previousMatch != null && previousMatch.end != match.start) {
      var tokenValue = sourceCode.substring(previousMatch.end, match.start);
      if (!allWhitespacePtn.hasMatch(tokenValue)) {
        yield Token(
          tokenValue,
          previousMatch.end,
          match.start,
        );
      }
    }

    yield Token(
      match.group(1),
      match.start,
      match.end,
    );

    previousMatch = match;
  }
}
