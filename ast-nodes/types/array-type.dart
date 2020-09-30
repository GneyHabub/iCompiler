import 'var-type.dart';
import 'expression.dart';
import 'integer-type.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';
import '../semantic-error.dart';
import '../symbol-table/scope-element.dart';

/// An array type with optional [size].
class ArrayType implements VarType {
  ScopeElement scopeMark;

  Expression size;
  VarType elementType;

  ArrayType(this.size, this.elementType);

  factory ArrayType.parse(Iterable<Token> tokens) {
    var iterator = tokens.iterator;
    checkNext(iterator, RegExp('array\$'), "Expected 'array'");
    checkNext(iterator, RegExp('\\[\$'), "Expected '['");
    iterator.moveNext();
    var sizeTokens = consumeUntil(iterator, RegExp("\\]\$"));
    checkThis(iterator, RegExp('\\]\$'), "Expected ']'");
    iterator.moveNext();
    var type = VarType.parse(consumeFull(iterator));

    Expression size = null;
    if (!sizeTokens.isEmpty) {
      size = Expression.parse(sizeTokens);
    }

    return ArrayType(size, type);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}ArrayType', depth)
      + (this.size?.toString(depth: depth + 1, prefix: 'size: ') ?? '')
      + (this.elementType?.toString(depth: depth + 1, prefix: 'element type: ') ?? '')
    );
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.size?.propagateScopeMark(parentMark);
    this.elementType.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.size.checkSemantics();
    if (!this.size.isConstant) {
      throw SemanticError(this.size, 'The array size must be a constant expression');
    }
    if (this.size.resultType is! IntegerType) {
      throw SemanticError(this.size, 'The array size must be integer');
    }
    this.elementType.checkSemantics();
  }
}
