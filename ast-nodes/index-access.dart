import 'modifiable-primary.dart';
import 'expression.dart';

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
  Expression index;
  ModifiablePrimary object;

  IndexAccess(this.index, this.object);

  // TODO: implement .parse()
}
