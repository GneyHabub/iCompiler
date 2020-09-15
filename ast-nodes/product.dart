import 'sum.dart';
import 'expression.dart';
import 'mul-operator.dart';
import 'div-operator.dart';
import 'mod-operator.dart';
import '../lexer.dart';
import '../iterator-utils.dart';

/// An abstract multiplying operator.
abstract class Product implements Sum {
  factory Product.parse(Iterable<Token> tokens) {
    final iter = tokens.iterator;
    iter.moveNext();
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
