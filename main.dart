import 'dart:io';
import 'lexer.dart';
import 'syntax-error.dart';
import 'ast-nodes/index.dart';

void main(List<String> args) {
  File sourceFile;
  try {
    sourceFile = File(args.length == 1 ? args[0] : './tests/arithmetic.isc');
  } on FileSystemException {
    print("The source file '${args[0]}' couldn't be found.");
    return;
  }

  try {
    var tokens = splitToTokens(sourceFile.readAsStringSync());
    var programAST = Program.parse(tokens);
    var symbolTable = programAST.buildSymbolTable();
    programAST.checkSemantics();
    print(programAST);
  } on SyntaxError catch (e) {
    print(e);
  }
}
