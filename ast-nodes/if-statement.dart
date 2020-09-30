import 'statement.dart';
import 'expressions/expression.dart';
import 'declaration.dart';
import 'scope-creator.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';
import '../syntax-error.dart';
import '../symbol-table/scope.dart';
import '../symbol-table/scope-element.dart';

/// A conditional statement.
class IfStatement implements Statement, ScopeCreator {
  ScopeElement scopeMark;
  List<Scope> scopes;

  Expression condition;
  List<Statement> blockTrue;
  List<Statement> blockFalse;

  IfStatement(this.condition, this.blockTrue, this.blockFalse);

  factory IfStatement.parse(Iterable<Token> tokens) {
    final nestedBlockStart = RegExp("(record|for|if|while)\$");
    final nestedBlockEnd = RegExp("end\$");
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('if\$'), "Expected 'if'");
    iterator.moveNext();
    var condition = Expression.parse(consumeUntil(iterator, RegExp("then\$")));
    checkThis(iterator, RegExp('then\$'), "Expected 'then'");
    iterator.moveNext();

    var trueBlock = Statement.parseBody(consumeAwareUntil(
      iterator,
      nestedBlockStart,
      nestedBlockEnd,
      RegExp('(end|else)\$'),
    ));

    if (trueBlock.isEmpty) {
      throw SyntaxError(
          iterator.current, "Expected at least one statement in the block");
    }

    List<Statement> falseBlock = [];
    if (iterator.current?.value == "else") {
      iterator.moveNext();
      falseBlock = Statement.parseBody(consumeAwareUntil(
          iterator, nestedBlockStart, nestedBlockEnd, nestedBlockEnd));

      if (falseBlock.isEmpty) {
        throw SyntaxError(
            iterator.current, "Expected at least one statement in the block");
      }

      checkThis(iterator, nestedBlockEnd, "Expected 'end'");
      checkNoMore(iterator);
    } else if (iterator.current?.value == "end") {
      checkNoMore(iterator);
    } else {
      throw SyntaxError(iterator.current, "Expected 'else' or 'end'");
    }

    return IfStatement(condition, trueBlock, falseBlock);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}IfStatement', depth) +
        (this.condition?.toString(depth: depth + 1, prefix: 'condition: ') ??
            '') +
        drawDepth('true block:', depth + 1) +
        this
            .blockTrue
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join('') +
        drawDepth('false block:', depth + 1) +
        this
            .blockFalse
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.condition.propagateScopeMark(parentMark);

    var scopeTrue = Scope();
    var scopeFalse = Scope();
    this.scopes = [scopeTrue, scopeFalse];
    var bodies = <List<Statement>>[this.blockTrue, this.blockFalse];

    for (var i = 0; i < bodies.length; ++i) {
      ScopeElement currentMark = this.scopes[i].lastChild;
      for (var statement in bodies[i]) {
        statement.propagateScopeMark(currentMark);
        if (statement is Declaration) {
          currentMark = this.scopes[i].addDeclaration(statement);
        }
        if (statement is ScopeCreator) {
          (statement as ScopeCreator)
              .scopes
              .forEach((subscope) => this.scopes[i].addSubscope(subscope));
        }
      }
    }
  }

  void checkSemantics() {
    // TODO: implement
  }
}
