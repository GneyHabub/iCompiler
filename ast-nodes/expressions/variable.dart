import 'literal.dart';
import 'modifiable-primary.dart';
import '../types/var-type.dart';
import '../variable-declaration.dart';
import '../../print-utils.dart';
import '../../symbol-table/scope-element.dart';
import '../../semantic-error.dart';

/// A variable reference by [name] – for either reading or writing.
class Variable implements ModifiablePrimary {
  VarType resultType;
  bool isConstant = false;
  ScopeElement scopeMark;

  String name;

  Variable(this.name);

  String toString({int depth = 0, String prefix = ''}) {
    return drawDepth('${prefix}Variable("${this.name}")', depth);
  }

  Literal evaluate() {
    throw StateError("Can't evaluate a non-constant expression");
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {
    var declaration = this.scopeMark.resolve(this.name);
    if (declaration is! VariableDeclaration) {
      throw SemanticError(this, "Variable ${this.name} is not declared");
    }
    this.resultType = (declaration as VariableDeclaration).type.resolve();
  }
}
