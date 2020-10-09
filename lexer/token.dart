/// A lexer token.
class Token {
  final String value;
  final int start;
  final int end;

  String toString() {
    return '"${value == '\n' ? '\\n' : value}":${start}–${end}';
  }

  const Token(this.value, this.start, this.end);
}
