import 'statement.dart';
import 'modifiable-primary.dart';
import 'expression.dart';

/// An assignment of the value on the right hand side ([rhs]) to the left hand side ([lhs]).
class Assignment implements Statement {
  ModifiablePrimary lhs;
  Expression rhs;

  Assignment(this.lhs, this.rhs);

  // TODO: implement .parse()
}
