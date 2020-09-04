import 'modifiable-primary.dart';

/// A variable reference by [name] – for either reading or writing.
class Variable implements ModifiablePrimary {
  String name;

  Variable(this.name);

  // TODO: implement .parse()
}
