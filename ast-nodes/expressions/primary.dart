import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';

/// An abstract value.
abstract class Primary implements Product {
  factory Primary.parse(Iterable<Token> tokens) {
    var iter = tokens.iterator;
    if (!iter.moveNext()) {
      throw SyntaxError(tokens.first, 'Expected a primary');
    }
    if (iter.current.value == '-') {
      iter.moveNext();
      return NegOperator(Primary.parse(consumeFull(iter)));
    } else if (iter.current.value == '+') {
      iter.moveNext();
      return PosOperator(Primary.parse(consumeFull(iter)));
    } else if (iter.current.value == 'true') {
      checkNoMore(iter);
      return BooleanLiteral(true);
    } else if (iter.current.value == 'false') {
      checkNoMore(iter);
      return BooleanLiteral(false);
    }

    var intLiteral = int.tryParse(iter.current.value);
    if (intLiteral != null) {
      checkNoMore(iter);
      return IntegerLiteral(intLiteral);
    }

    var realLiteral = double.tryParse(iter.current.value);
    if (realLiteral != null) {
      checkNoMore(iter);
      return RealLiteral(realLiteral);
    }

    iter.moveNext();
    if (iter.current?.value == '(') {
      return RoutineCall.parse(tokens);
    }

    return ModifiablePrimary.parse(tokens);
  }
}
