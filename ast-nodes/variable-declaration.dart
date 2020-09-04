import 'declaration.dart';
import 'var-type.dart';
import 'expression.dart';
import '../lexer.dart';

/// A variable declaration contains a [type] and the initial [value].
///
/// Both of these can be set to [null].
class VariableDeclaration extends Declaration {
  VarType type;
  Expression value;

  VariableDeclaration(name, this.type, this.value) : super(name);

  factory VariableDeclaration.parse(Iterable<Token> tokens) {
    // TODO: write the actual parser body
    return VariableDeclaration('dummy', null, null);
  }
}
