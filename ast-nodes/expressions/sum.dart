import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';

/// An abstract summing operator.
abstract class Sum implements Comparison {
  factory Sum.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    var product = <Token>[];

    var parentheses = 0;
    Token prevToken = null;
    while (iter.moveNext()) {
      if (['(', '['].contains(iter.current?.value)) {
        parentheses++;
      }
      if ([')', ']'].contains(iter.current?.value)) {
        parentheses--;
      }
      if (parentheses == 0 &&
          ['+', '-'].contains(iter.current?.value) &&
          !['(', '%', '*', '/', null].contains(prevToken?.value)) {
        break;
      }
      product.add(iter.current);
      prevToken = iter.current;
    }
    if (iter.current?.value == '+') {
      iter.moveNext();
      return AddOperator(Product.parse(product), Sum.parse(consumeFull(iter)));
    } else if (iter.current?.value == '-') {
      iter.moveNext();
      return SubOperator(Product.parse(product), Sum.parse(consumeFull(iter)));
    } else {
      return Product.parse(product);
    }
  }
}
