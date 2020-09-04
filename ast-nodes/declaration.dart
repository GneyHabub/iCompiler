import 'statement.dart';

/// A declaration is a [Statement] that creates a new entity with a [name].
abstract class Declaration implements Statement {
  String name;

  Declaration(this.name);
}
