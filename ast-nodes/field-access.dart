import 'modifiable-primary.dart';
import '../print-utils.dart';

/// A record field access by [name] – for either reading or writing.
///
/// Chained field access requires several [FieldAccess] objects:
/// ```dart
/// // "a.b.c" is represented with
/// FieldAccess("c", FieldAccess("b", Variable("a")))
/// ```
class FieldAccess implements ModifiablePrimary {
  String name;
  ModifiablePrimary object;

  FieldAccess(this.name, this.object);

  String toString({int depth = 0, String prefix = ''}) {
    return (
      drawDepth('${prefix}FieldAccess("${this.name}")', depth)
      + (this.object?.toString(depth: depth + 1, prefix: 'object: ') ?? '')
    );
  }
}
