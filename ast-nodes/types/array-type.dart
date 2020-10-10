import 'dart:ffi';
import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

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
    return (drawDepth('${prefix}ArrayType', depth) +
        (this.size?.toString(depth: depth + 1, prefix: 'size: ') ?? '') +
        (this
                .elementType
                ?.toString(depth: depth + 1, prefix: 'element type: ') ??
            ''));
  }

  @override
  bool operator ==(Object other) {
    if (other is NamedType) {
      return this ==
          (other.scopeMark.resolve(other.name) as TypeDeclaration).value;
    }

    try {
      return (other is ArrayType &&
          (this.size == null ||
              other.size == null ||
              this.size.evaluate() == other.size.evaluate()) &&
          this.elementType == other.elementType);
    } on StateError {
      return false;
    }
  }

  @override
  int get hashCode {
    return 0;
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.size?.propagateScopeMark(parentMark);
    this.elementType.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    if (this.size != null) {
      this.size.checkSemantics();
      if (!this.size.isConstant) {
        throw SemanticError(
            this.size, 'The array size must be a constant expression');
      }
      if (this.size.resultType is! IntegerType) {
        throw SemanticError(this.size, 'The array size must be integer');
      }
    }
    this.elementType.checkSemantics();
  }

  VarType resolve() {
    return this;
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }

  Pointer<LLVMOpaqueType> getLlvmType(Module module) {

  }
}
