import 'sum.dart';
import '../lexer.dart';
import 'expression.dart';

/// An abstract multiplying operator.
abstract class Product implements Sum {
  factory Product.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    List<Token> expr = consumeUntil(iter, RegExp('[*/%]\$'));

      if (iter.current?.value == '*') {
      iter.moveNext();
      return MulOperator(Expression.parsePrioritized(expr), Product.parse(consumeFull(iter)));
    } else if (iter.current?.value == '/') {
      iter.moveNext();
      return DivOperator(Expression.parsePrioritized(expr), Product.parse(consumeFull(iter)));
    } else if (iter.current?.value == '%') {
      iter.moveNext();
      return ModOperator(Expression.parsePrioritized(expr), Product.parse(consumeFull(iter)));
    } else {
      return Expression.parsePrioritized(expr);
    }
  }
}

//Product ::= Prioritized [ ( '*' | '/' | '%' ) Product ]
