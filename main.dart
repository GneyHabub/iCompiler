import 'dart:io';

class Token {
  final String value;
  final int start;
  final int end;
  final int type = null;
  final bool isFaulty;
  String toString(){
    return 'Token "${value == '\n' ? '\\n' : value}", ${start}–${end}';
  }
  const Token(this.value, this.start, this.end, {this.isFaulty});
}

RegExp langTokenPtn = new RegExp(
  "([a-zA-Z_]\\w*|[0-9.]|[:;(),\\[\\]=.<>\/*%+\n-])",
  multiLine: true,
);

List<Token> lexer(path){
  var tokens = <Token>[];
  var fileContents = new File(path).readAsStringSync();
  Iterable<RegExpMatch> iterator = langTokenPtn.allMatches(fileContents);

  RegExpMatch previousMatch = null;
  for (RegExpMatch match in iterator) {
    if (previousMatch != null && previousMatch.end != match.start) {
      tokens.add(new Token(
        fileContents.substring(previousMatch.end, match.start),
        previousMatch.end,
        match.start,
        isFaulty: true,
      ));
    }
    tokens.add(new Token(
      match.group(1),
      match.start,
      match.end,
      isFaulty: false,
    ));
    previousMatch = match;
  }

  return tokens;
}

void main(){
  List<Token> tokensList = lexer('./tests/bubble_sort.isc');
  tokensList.forEach((element) {
    print(element);
  });
}
