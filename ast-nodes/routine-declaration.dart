import 'declaration.dart';
import 'parameter.dart';
import 'var-type.dart';
import 'statement.dart';
import '../lexer.dart';
import '../print-utils.dart';

/// A routine declaration has [parameters], a [returnType] and a [body].
class RoutineDeclaration extends Declaration {
  List<Parameter> parameters;
  VarType returnType;
  List<Statement> body;

  RoutineDeclaration(name, this.parameters, this.returnType, this.body) : super(name);

  factory RoutineDeclaration.parse(Iterable<Token> tokens) {
 
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('routine\$'), "Expected 'routine'");
    checkNext(iterator, RegExp('[a-zA-Z_]\w*\$'), "Expected identifier");
    checkNext(iterator, RegExp("\\("), "Expected '('");
    var par = Parameter.parse(consumeUntil(iterator, RegExp("\\)")));
    checkThis(iterator, RegExp("\\)"), "Expected ')'");
    var type = VarType.parse(consumeUntil(iterator, RegExp('is\$')));
    checkThis(iterator, RegExp('is\$'));
    var bodyTokens = consumeUntil(iterator, RegExp("^end\$"));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    if (type.isEmpty) {
      throw SyntaxError(iterator.current, "Expected a type");
    }

    var roparameters = List<Parameter>.parse(par);
    var rotype = VarType.parse(type);
    var robody = List<Statement>.parse(bodyTokens);

    return RoutineDeclaration(myroutine, roparameters, rotype, robody);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}RoutineDeclaration("${this.name}")', depth)
      + drawDepth('parameters:', depth + 1)
      + this.parameters.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
      + (this.returnType?.toString(depth: depth + 1, prefix: 'return type: ') ?? '')
      + drawDepth('body:', depth + 1)
      + this.body.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
    );
  }
}
