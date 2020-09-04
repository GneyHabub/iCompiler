import 'dart:io';
import 'lexer.dart';
import 'syntax-error.dart';

void main() {
  try {
    splitToTokens(File('./tests/bubble_sort.isc').readAsStringSync()).forEach(print);
  } on SyntaxError catch (e) {
    print(e);
  }
}
