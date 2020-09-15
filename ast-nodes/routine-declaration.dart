import 'declaration.dart';
import 'parameter.dart';
import 'var-type.dart';
import 'statement.dart';
import '../lexer.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';

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
    var routineName = iterator.current.value;

    checkNext(iterator, RegExp("\\("), "Expected '('");
    var parameterTokens = consumeUntil(iterator, RegExp("\\)\$"));
    checkThis(iterator, RegExp("\\)"), "Expected ')'");
    iterator.moveNext();

    VarType returnType = null;
    if (iterator.current?.value == ":"){
      iterator.moveNext();
      returnType = VarType.parse(consumeUntil(iterator, RegExp('is\$')));
    }

    checkThis(iterator, RegExp('is\$'), "Expected 'is'");
    var bodyTokens = consumeUntil(iterator, RegExp("end\$"));
    print(bodyTokens);
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var roparameters = <Parameter>[];
    var parsIterator = parameterTokens.iterator;
    while (parsIterator.moveNext()) {
      var blockTokens = consumeUntil(parsIterator, RegExp(",\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      roparameters.add(Parameter.parse(blockTokens));
    }

    var bodyIterator = bodyTokens.iterator;
    var robody = <Statement>[];
    while (bodyIterator.moveNext()) {
      var blockTokens = consumeUntil(bodyIterator, RegExp("[\n;]\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      robody.add(Statement.parse(blockTokens));
    }

    return RoutineDeclaration(routineName, roparameters, returnType, robody);
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
