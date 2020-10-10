import 'dart:ffi';
import 'routine-declaration.dart';
import '../symbol-table/index.dart';
import '../codegen/index.dart';

/// A built-in routine declaration doesn't appear in code but instead does a predefined action.
class BuiltinRoutineDeclaration extends RoutineDeclaration {
  BuiltinRoutineDeclaration(name, parameters, returnType)
      : super(name, parameters, returnType, []);

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
  }

  void checkSemantics() {}

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    // TODO: implement
    return null;
  }
}
