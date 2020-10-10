import 'dart:io';
import 'lexer/split-to-tokens.dart';
import 'errors/index.dart';
import 'ast-nodes/index.dart';
import 'codegen/index.dart';

void main(List<String> args) {
  File sourceFile;
  try {
    sourceFile = File(args.length == 1 ? args[0] : './tests/arithmetic.isc');
  } on FileSystemException {
    print("The source file '${args[0]}' couldn't be found.");
    return;
  }

  try {
    var llvmModule = Module(sourceFile.path);
    var tokens = splitToTokens(sourceFile.readAsStringSync());
    var programAST = Program.parse(tokens);
    programAST.buildSymbolTable();
    programAST.checkSemantics();
    programAST.generateCode(llvmModule);
    print(llvmModule);
  } on SyntaxError catch (e) {
    print(e);
  }

  MemoryManager.dispose();
}
