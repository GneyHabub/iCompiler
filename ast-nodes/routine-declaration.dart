import 'declaration.dart';
import 'parameter.dart';
import 'var-type.dart';
import 'statement.dart';
import '../lexer.dart';

/// A routine declaration has [parameters], a [returnType] and a [body].
class RoutineDeclaration extends Declaration {
  List<Parameter> parameters;
  VarType returnType;
  List<Statement> body;

  RoutineDeclaration(name, this.parameters, this.returnType, this.body) : super(name);

  factory RoutineDeclaration.parse(Iterable<Token> tokens) {
    // TODO: write the actual parser body
    return RoutineDeclaration('dummy', null, null, null);
  }
}
