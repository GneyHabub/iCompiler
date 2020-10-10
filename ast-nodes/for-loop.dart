import 'dart:ffi';
import 'index.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../lexer/token.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A `for` loop.
class ForLoop implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Variable loopVariable;
  Range range;
  List<Statement> body;

  ForLoop(this.loopVariable, this.range, this.body);

  factory ForLoop.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('for\$'), "Expected 'for'");
    checkNext(iterator, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    if (isReserved(iterator.current.value)) {
      throw SyntaxError(iterator.current,
          "The '${iterator.current.value}' keyword is reserved");
    }
    var loopVariable = Variable(iterator.current.value);
    checkNext(iterator, RegExp('in\$'), "Expected 'in'");
    iterator.moveNext();
    var range = Range.parse(consumeUntil(iterator, RegExp('loop\$')));
    checkThis(iterator, RegExp('loop\$'), "Expected 'loop'");
    iterator.moveNext();
    var bodyTokens = consumeAwareUntil(
      iterator,
      RegExp('(record|for|while|if)\$'),
      RegExp('end\$'),
      RegExp('end\$'),
    );
    checkThis(iterator, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iterator);

    var statements = Statement.parseBody(bodyTokens);
    if (statements.isEmpty) {
      throw SyntaxError(
          iterator.current, 'Expected at least one statement in a loop body');
    }

    return ForLoop(loopVariable, range, statements);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('ForLoop', depth) +
        (this
                .loopVariable
                ?.toString(depth: depth + 1, prefix: 'loop variable: ') ??
            '') +
        (this.range?.toString(depth: depth + 1, prefix: 'range: ') ?? '') +
        drawDepth('body:', depth + 1) +
        this
            .body
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.loopVariable.propagateScopeMark(parentMark);
    this.range.propagateScopeMark(parentMark);

    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.addDeclaration(
        VariableDeclaration(this.loopVariable.name, IntegerType(), null));

    for (var statement in this.body) {
      statement.propagateScopeMark(currentMark);
      if (statement is Declaration) {
        currentMark = scope.addDeclaration(statement);
      }

      if (statement is ScopeCreator) {
        (statement as ScopeCreator)
            .scopes
            .forEach((subscope) => scope.addSubscope(subscope));
      }
    }
  }

  void checkSemantics() {
    this.range.checkSemantics();
    for (var statement in this.body) {
      statement.checkSemantics();
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
