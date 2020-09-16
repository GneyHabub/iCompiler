import 'var-type.dart';
import 'expression.dart';
import '../print-utils.dart';
import '../iterator-utils.dart';
import '../lexer.dart';

/// An array type with optional [size].
class ArrayType implements VarType {
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
}
