import 'var-type.dart';

/// An array type with optional [size].
class ArrayType implements VarType {
  int size;
  VarType elementType;

  ArrayType(this.size, this.elementType);

  // TODO: implement .parse()
}
