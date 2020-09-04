import 'var-type.dart';
import 'variable-declaration.dart';

/// A compound type that has several [fields] inside.
class RecordType implements VarType {
  List<VariableDeclaration> fields;

  RecordType(this.fields);

  // TODO: implement .parse()
}
