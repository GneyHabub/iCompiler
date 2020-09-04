import 'node.dart';
import 'var-type.dart';

/// A routine parameter, characterized by the [name] and the [type].
class Parameter implements Node {
  String name;
  VarType type;

  Parameter(this.name, this.type);

  // TODO: implement .parse()
}
