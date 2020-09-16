import 'var-type.dart';
import 'variable-declaration.dart';
import '../lexer.dart';
import '../syntax-error.dart';
import '../iterator-utils.dart';
import '../print-utils.dart';

/// A compound type that has several [fields] inside.
class RecordType implements VarType {
  List<VariableDeclaration> fields;

  RecordType(this.fields);

  factory RecordType.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('record\$'), "Expected 'record'");
    iterator.moveNext();
    var bodyTokens = consumeUntil(iterator, RegExp("^end\$"));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var declarations = <VariableDeclaration>[];
    var bodyIterator = bodyTokens.iterator;

    while (bodyIterator.moveNext()) {
      var declarationTokens = consumeAwareUntil(
        bodyIterator,
        RegExp('record\$'),
        RegExp('end\$'),
        RegExp("^[\n;]\$")
      );
      if (declarationTokens.isEmpty) {
        continue;
      }

      declarations.add(VariableDeclaration.parse(declarationTokens));
    }

    if (declarations.isEmpty) {
      throw SyntaxError(iterator.current, "Expected at least one field in a record");
    }

    return RecordType(declarations);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}RecordType', depth)
      + drawDepth('fields:', depth + 1)
      + this.fields.map((node) => node?.toString(depth: depth + 2) ?? '').join('')
    );
  }
}
