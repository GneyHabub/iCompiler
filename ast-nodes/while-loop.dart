import 'index.dart';
import '../lexer/token.dart';
import '../utils/index.dart';
import '../errors/index.dart';
import '../symbol-table/index.dart';

/// A `while` loop.
class WhileLoop implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Expression condition;
  List<Statement> body;

  WhileLoop(this.condition, this.body);

  factory WhileLoop.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    checkNext(iter, RegExp('while\$'), "Expected 'while'");
    iter.moveNext();
    var loopCondition = consumeUntil(iter, RegExp('loop\$'));

    if (loopCondition.isEmpty) {
      throw SyntaxError(iter.current, "Expected a condition");
    }

    checkThis(iter, RegExp('loop\$'), "Expected 'loop'");
    iter.moveNext();
    var loopBody = consumeUntil(iter, RegExp('end\$'));

    if (loopBody.isEmpty) {
      throw SyntaxError(
          iter.current, 'Expected at least one statement in a loop body');
    }

    checkThis(iter, RegExp('end\$'), "Expected 'end'");
    checkNoMore(iter);

    var statements = Statement.parseBody(loopBody);

    return WhileLoop(Expression.parse(loopCondition), statements);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}WhileLoop', depth) +
        (this.condition?.toString(depth: depth + 1, prefix: 'condition: ') ??
            '') +
        drawDepth('body:', depth + 1) +
        this
            .body
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.condition.propagateScopeMark(parentMark);

    var scope = Scope();
    this.scopes = [scope];
    ScopeElement currentMark = scope.lastChild;

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
    this.condition.checkSemantics();
    this.condition = ensureType(this.condition, BooleanType());
    for (var statement in this.body) {
      statement.checkSemantics();
    }
  }
}
