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
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    var routineName = iterator.current.value;

    checkNext(iterator, RegExp("\\("), "Expected '('");
    iterator.moveNext();
    var parameterTokens = consumeUntil(iterator, RegExp("\\)\$"));
    checkThis(iterator, RegExp("\\)"), "Expected ')'");
    iterator.moveNext();

    VarType returnType = null;
    if (iterator.current?.value == ":"){
      iterator.moveNext();
      returnType = VarType.parse(consumeAwareUntil(
        iterator,
        RegExp('record\$'),
        RegExp('end\$'),
        RegExp('is\$')
      ));
    }

    checkThis(iterator, RegExp('is\$'), "Expected 'is'");
    iterator.moveNext();
    var body = Statement.parseBody(consumeAwareUntil(
      iterator,
      RegExp('(record|if|while|for)\$'),
      RegExp('end\$'),
      RegExp('end\$'),
    ));

    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var parameters = <Parameter>[];
    var parsIterator = parameterTokens.iterator;
    while (parsIterator.moveNext()) {
      var blockTokens = consumeUntil(parsIterator, RegExp(",\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      parameters.add(Parameter.parse(blockTokens));
    }

    return RoutineDeclaration(routineName, parameters, returnType, body);
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
