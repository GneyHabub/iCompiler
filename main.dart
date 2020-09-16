import 'dart:io';
import 'lexer.dart';
import 'syntax-error.dart';
import 'ast-nodes/index.dart';

void main() {
  try {
    var tokens = splitToTokens(File('./tests/while.isc').readAsStringSync());
    print(Program.parse(tokens));
  } on SyntaxError catch (e) {
    print(e);
  }
}
