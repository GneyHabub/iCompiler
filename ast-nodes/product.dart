import 'sum.dart';
import '../lexer.dart';
import 'expression.dart';

/// An abstract multiplying operator.
abstract class Product implements Sum {
  factory Product.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    List<Token> expr = consumeUntil(iter, RegExp('[*/%]\$'));
    var wholeExpression = Expression.parsePrioritized(expr);

    if (iter.current?.value == '*') {
      iter.moveNext();
      return MulOperator(Product.parse(product), Sum.parse(consumeFull(iter)));
    } else if (iter.current?.value == '/') {
      iter.moveNext();
      return DivOperator(Product.parse(product), Sum.parse(consumeFull(iter)));
    } else {
      return Product.parse(product);
    }
  }
}
