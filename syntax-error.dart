import 'lexer.dart';

/// A syntax error in the parsed source code.
///
/// Uses the [faultyToken] to give a helpful error message.
class SyntaxError implements Exception {
  String cause;
  Token faultyToken;

  SyntaxError(this.faultyToken, this.cause);

  String toString() {
    return this.cause;
  }
}
