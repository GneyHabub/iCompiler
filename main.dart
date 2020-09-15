import 'dart:io';
import 'lexer.dart';
import 'syntax-error.dart';
import 'ast-nodes/index.dart';

void main() {
  try {
    Program.parse(splitToTokens(File('./tests/bubble_sort.isc').readAsStringSync()));
  } on SyntaxError catch (e) {
    print(e);
  }
}
