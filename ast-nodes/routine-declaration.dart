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
    checkNext(iterator, RegExp("\\("), "Expected '('");
    var par = consumeUntil(iterator, RegExp("\\)"));
    checkThis(iterator, RegExp("\\)"), "Expected ')'");
    iterator.moveNext();
    List<Token> type = null;
    if (iterator.current?.value == ":"){
      type = VarType.parse(consumeUntil(iterator, RegExp('is\$')));
    }
    checkThis(iterator, RegExp('is\$'));
    var bodyTokens = consumeUntil(iterator, RegExp("^end\$"));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var roparameters = <Parameter>[];
    var parsIterator = par.iterator;
    while (parsIterator.moveNext()) {
      var blockTokens = consumeUntil(parsIterator, RegExp(",\$"));
      if (blockTokens.isEmpty) {
        continue;
      }
      roparameters.add(Parameter.parse(blockTokens));
    }

    VarType rotype = null;

    if (type != null) {
      rotype = VarType.parse(type);
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
