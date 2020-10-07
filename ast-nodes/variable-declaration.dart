import '../iterator-utils.dart';
import '../parser-utils.dart';
import '../syntax-error.dart';
import 'declaration.dart';
import 'types/var-type.dart';
import 'expressions/expression.dart';
import '../lexer.dart';
import '../print-utils.dart';
import '../symbol-table/scope-element.dart';

/// A variable declaration contains a [type] and the initial [value].
///
/// Both of these can be set to [null].
class VariableDeclaration extends Declaration {
  ScopeElement scopeMark;

  VarType type;
  Expression value;

  VariableDeclaration(name, this.type, this.value) : super(name);

  factory VariableDeclaration.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    checkNext(iter, RegExp('var\$'), 'Expected "var"');
    checkNext(iter, RegExp('[A-Za-z_]\\w*\$'), 'Expected identifier');
    if (isReserved(iter.current.value)) {
      throw SyntaxError(
          iter.current, 'The "${iter.current.value}" keyword is reserved');
    }
    final name = iter.current.value;
    iter.moveNext();
    VarType type = null;
    Expression initialValue = null;

    if (iter.current?.value == ':') {
      iter.moveNext();
      type = VarType.parse(consumeAwareUntil(
          iter, RegExp('record\$'), RegExp('end\$'), RegExp('is\$')));
      if (iter.current?.value == 'is') {
        iter.moveNext();
        initialValue = Expression.parse(consumeFull(iter));
      }
    } else if (iter.current?.value == 'is') {
      iter.moveNext();
      initialValue = Expression.parse(consumeFull(iter));
    } else {
      throw SyntaxError(iter.current, 'Expected ":" or "is"');
    }

    return VariableDeclaration(name, type, initialValue);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}VariableDeclaration("${this.name}")', depth) +
        (this.type?.toString(depth: depth + 1, prefix: 'type: ') ?? '') +
        (this.value?.toString(depth: depth + 1, prefix: 'value: ') ?? ''));
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.type?.propagateScopeMark(parentMark);
    this.value?.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.type.checkSemantics();
    this.value.checkSemantics();
    if (this.type != null && this.value != null) {
      var expType = this.value.resultType;
      if (this.type is RecordType || this.type is ArrayType || this.type is NamedType || 
          expType is RecordType || expType is ArrayType || expType is NamedType) {
        if (this.type != this.value.returnType) {
          throw SemanticError(this, "Cannot declare variable from expression of different type");
        }
      } else if (expType is RealType && this.type is BooleanType) {
        if (this.type != this.value.returnType) {
          throw SemanticError(this, "Cannot declare variable from expression of different type");
        }
      }
    } else {
      throw SemanticError(this, "Null reference exception");
    }
    this.value = ensureType(this.value, this.type);
  }
}
