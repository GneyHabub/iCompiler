import 'dart:io';
import 'lexer.dart';
import 'syntax-error.dart';
import 'ast-nodes/index.dart';

void main() {
  try {
    var tokens = splitToTokens(
        File('./tests/bubble_sort_corrected.isc').readAsStringSync());
    print(Program.parse(tokens));
  } on SyntaxError catch (e) {
    print(e);
  }
}
