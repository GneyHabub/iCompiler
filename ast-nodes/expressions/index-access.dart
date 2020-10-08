import 'modifiable-primary.dart';
import 'literal.dart';
import 'expression.dart';
import '../types/var-type.dart';
import '../types/array-type.dart';
import '../types/integer-type.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope-element.dart';
import '../../semantic-error.dart';
import '../../semantic-utils.dart';

/// An array element access by [index] – for either reading or writing.
///
/// Chained element access requires several [IndexAccess] objects:
/// ```dart
/// // "a[0][1]" is represented with
/// IndexAccess(
///   IntegerLiteral(1),
///   IndexAccess(
///     IntegerLiteral(0),
///     Variable("a"),
///   ),
/// )
/// ```
class IndexAccess implements ModifiablePrimary {
  VarType resultType;
  bool isConstant = false;
  ScopeElement scopeMark;

  Expression index;
  ModifiablePrimary object;

  IndexAccess(this.index, this.object);

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}IndexAccess', depth) +
        (this.index?.toString(depth: depth + 1, prefix: 'index: ') ?? '') +
        (this.object?.toString(depth: depth + 1, prefix: 'object: ') ?? ''));
  }

  Literal evaluate() {
    throw StateError("Can't evaluate a non-constant expression");
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    this.index.propagateScopeMark(parentMark);
    this.object.propagateScopeMark(parentMark);
  }

  void checkSemantics() {
    this.object.checkSemantics();
    this.index.checkSemantics();
    this.index = ensureType(this.index, IntegerType());

    if (this.object.resultType is! ArrayType) {
      throw SemanticError(this, "Only arrays can be indexed");
    }

    this.resultType = (this.object.resultType as ArrayType).elementType;
  }
}
