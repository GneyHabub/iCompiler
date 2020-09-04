import 'modifiable-primary.dart';

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

  // TODO: implement .parse()
}
