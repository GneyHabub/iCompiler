import 'product.dart';
import '../lexer.dart';
import '../syntax-error.dart';
import '../iterator-utils.dart';
import 'boolean-literal.dart';
import 'integer-literal.dart';
import 'real-literal.dart';
import 'modifiable-primary.dart';

/// An abstract value.
abstract class Primary implements Product {
  factory Primary.parse(Iterable<Token> tokens) {
    if (tokens.isEmpty) {
      throw SyntaxError(tokens.first, 'Expected a primary');
    }
    var iter = tokens.iterator;
    iter.moveNext();
    if (iter.current.value == 'true') {
      checkNoMore(iter);
      var bLBuffer = new BooleanLiteral(true);
      return bLBuffer;

    } else if (iter.current.value == 'false') {
      checkNoMore(iter);
      var bLBuffer = new BooleanLiteral(false);
      return bLBuffer;

    } else if (int.tryParse(iter.current.value) != null) {
        var iLBuffer = new IntegerLiteral(int.parse(iter.current.value));
        checkNoMore(iter);
        return iLBuffer;

    } else if (double.tryParse(iter.current.value) != null) {
        var rLBuffer = new RealLiteral(double.parse(iter.current.value));
        checkNoMore(iter);
        return rLBuffer;

    } else {
      return ModifiablePrimary.parse(tokens);
    }
  }
}
