# Changes to the official grammar of the I language by the noname team
## * Expression breakdown:
```
Expression ::= ( 'not' Expression | Comparison [ ( 'and' | 'or' | 'xor' ) Expression ] )
Comparison ::= Sum [ ( '<' | '<=' | '>' | '>=' | '=' | '/=' ) Comparison ]
Sum ::= Product [ ( '+' | '-' ) Sum ]
Product ::= Prioritized [ ( '*' | '/' | '%' ) Product ]
Prioritized ::= ( '(' Expression ')' | Primary )
Primary ::= ( '-' Primary | '+' Primary | IntegerLiteral | RealLiteral | BooleanLiteral | ModifiablePrimary | RoutineCall )
```
## + Return statement:
```
ReturnStatement ::= ‘return’ Expression
```

## * Range and ForLoop:
```
ForLoop ::= for Identifier in [ reverse ] Range loop Body end
Range ::= Expression .. Expression
```
### Legend
* \* - change/choose one of two contradicting
* \+ - add 