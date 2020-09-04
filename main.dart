import 'dart:io';

class Token {
  final String value;
  final int start;
  final int end;
  final bool isFaulty;

  String toString() {
    return 'Token "${value == '\n' ? '\\n' : value}", ${start}–${end}';
  }

  const Token(this.value, this.start, this.end, {this.isFaulty});
}

RegExp langTokenPtn = RegExp(
  "([a-zA-Z_]\\w*|[0-9]+(?:\\.[0-9]*)?|[:;(),\\[\\]=.<>\/*%+\n-])",
  multiLine: true,
);
RegExp allWhitespacePtn = RegExp("^\\s+\$");

Iterable<Token> lexer(String sourceCode) sync* {
  RegExpMatch previousMatch = null;
  for (var match in langTokenPtn.allMatches(sourceCode)) {
    if (previousMatch != null && previousMatch.end != match.start) {
      var tokenValue = sourceCode.substring(previousMatch.end, match.start);
      yield Token(
        tokenValue,
        previousMatch.end,
        match.start,
        isFaulty: !allWhitespacePtn.hasMatch(tokenValue),
      );
    }

    yield Token(
      match.group(1),
      match.start,
      match.end,
      isFaulty: false,
    );

    previousMatch = match;
  }
}

void main() {
  lexer(File('./tests/bubble_sort.isc').readAsStringSync()).forEach(print);
}
