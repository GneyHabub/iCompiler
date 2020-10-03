import 'var-type.dart';
import 'named-type.dart';
import '../type-declaration.dart';
import '../variable-declaration.dart';
import '../scope-creator.dart';
import '../../lexer.dart';
import '../../syntax-error.dart';
import '../../iterator-utils.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope.dart';
import '../../symbol-table/scope-element.dart';

/// A compound type that has several [fields] inside.
class RecordType implements VarType, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  List<VariableDeclaration> fields;

  RecordType(this.fields);

  factory RecordType.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('record\$'), "Expected 'record'");
    iterator.moveNext();
    var bodyTokens = consumeAwareUntil(
        iterator, RegExp('record\$'), RegExp('end\$'), RegExp("end\$"));
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var declarations = <VariableDeclaration>[];
    var bodyIterator = bodyTokens.iterator;

    while (bodyIterator.moveNext()) {
      var declarationTokens = consumeAwareUntil(bodyIterator,
          RegExp('record\$'), RegExp('end\$'), RegExp("^[\n;]\$"));
      if (declarationTokens.isEmpty) {
        continue;
      }
      declarations.add(VariableDeclaration.parse(declarationTokens));
    }

    if (declarations.isEmpty) {
      throw SyntaxError(
          iterator.current, "Expected at least one field in a record");
    }

    return RecordType(declarations);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}RecordType', depth) +
        drawDepth('fields:', depth + 1) +
        this
            .fields
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  @override
  bool operator ==(Object other) {
    if (other is NamedType) {
      return this ==
          (other.scopeMark.resolve(other.name) as TypeDeclaration).value;
    }

    if (other is! RecordType) {
      return false;
    }

    for (var i = 0; i < this.fields.length; ++i) {
      var thisField = this.fields[i];
      var otherField = (other as RecordType).fields[i];
      if (thisField.name != otherField.name ||
          thisField.type != otherField.type) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return 0;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;

    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.lastChild;

    for (var field in this.fields) {
      field.propagateScopeMark(currentMark);
      currentMark = scope.addDeclaration(field);
    }
  }

  void checkSemantics() {
    for (var declaration in this.fields) {
      declaration.checkSemantics();
    }
  }
}