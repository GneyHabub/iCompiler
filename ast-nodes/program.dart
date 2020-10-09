import 'node.dart';
import 'declaration.dart';
import 'variable-declaration.dart';
import 'type-declaration.dart';
import 'routine-declaration.dart';
import 'parameter.dart';
import 'builtin-routine-declaration.dart';
import 'scope-creator.dart';
import 'types/integer-type.dart';
import '../lexer.dart';
import '../iterator-utils.dart';
import '../print-utils.dart';
import '../syntax-error.dart';
import '../symbol-table/scope.dart';
import '../symbol-table/scope-element.dart';

/// A program is a list of [Declaration]s.
///
/// Declarations can be of three types:
///  - [VariableDeclaration]s
///  - [TypeDeclaration]s
///  - [RoutineDeclaration]s
class Program implements Node, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  List<Declaration> declarations;

  Program(this.declarations);

  factory Program.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    var declarations = <Declaration>[];

    var hadSemicolonBefore = false;

    while (iterator.moveNext()) {
      if (iterator.current.value == 'routine') {
        var routineTokens = consumeAwareUntil(
          iterator,
          RegExp('(record|while|for|if)\$'),
          RegExp('end\$'),
          RegExp('end\$'),
        );
        routineTokens.add(iterator.current);
        declarations.add(Declaration.parse(routineTokens));

        if (!iterator.moveNext()) {
          break;
        }

        if (iterator.current.value == ';') {
          hadSemicolonBefore = true;
        } else if (iterator.current.value == '\n') {
          hadSemicolonBefore = false;
        } else {
          throw SyntaxError(
              iterator.current, "Expected a newline or a semicolon");
        }
      } else {
        var declarationTokens = <Token>[];
        var recordCount = 0;
        do {
          if (iterator.current.value == 'record') {
            recordCount++;
          } else if (iterator.current.value == 'end') {
            recordCount--;
          }
          if ((iterator.current.value == ';' ||
                  iterator.current.value == '\n') &&
              recordCount == 0) {
            break;
          }

          declarationTokens.add(iterator.current);
        } while (iterator.moveNext());

        if (declarationTokens.isEmpty) {
          if (iterator.current.value == ';' && hadSemicolonBefore) {
            throw SyntaxError(iterator.current, 'Expected declaration');
          } else {
            continue;
          }
        }

        declarations.add(Declaration.parse(declarationTokens));
      }
    }

    return Program(declarations);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}Program', depth) +
        drawDepth('declarations:', depth + 1) +
        this
            .declarations
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  Scope buildSymbolTable() {
    this.propagateScopeMark(null);
    return this.scopes[0];
  }

  void propagateScopeMark(ScopeElement parentMark) {
    var scope = Scope();
    this.scopes = [scope];
    var currentMark = scope.lastChild;
    currentMark = scope.addDeclaration(BuiltinRoutineDeclaration(
        "print", [Parameter("value", IntegerType())], null));

    for (var declaration in this.declarations) {
      declaration.propagateScopeMark(currentMark);
      currentMark = scope.addDeclaration(declaration);

      if (declaration is ScopeCreator) {
        (declaration as ScopeCreator)
            .scopes
            .forEach((subscope) => scope.addSubscope(subscope));
      }
    }
  }

  void checkSemantics() {
    for (var declaration in this.declarations) {
      declaration.checkSemantics();
    }
  }
}
