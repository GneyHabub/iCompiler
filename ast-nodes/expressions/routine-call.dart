import 'dart:ffi';
import '../index.dart';
import '../../lexer/token.dart';
import '../../utils/index.dart';
import '../../errors/index.dart';
import '../../symbol-table/index.dart';
import '../../codegen/index.dart';

/// A routine call by [name], passing zero or more [arguments].
class RoutineCall implements Primary {
  VarType resultType;
  bool isConstant = false;
  ScopeElement scopeMark;

  String name;
  List<Expression> arguments;

  RoutineCall(this.name, this.arguments);

  factory RoutineCall.parse(Iterable<Token> tokens) {
    final openingParenthesis = RegExp('\\(\$');
    final closingParenthesis = RegExp('\\)\$');
    final iter = tokens.iterator;
    checkNext(iter, RegExp('[a-zA-Z_]\\w*\$'), "Expected identifier");
    final routineName = iter.current.value;
    if (isReserved(routineName)) {
      throw SyntaxError(iter.current, 'The "$routineName" keyword is reserved');
    }

    checkNext(iter, openingParenthesis, 'Expected "("');
    iter.moveNext();
    var argumentTokens = consumeAwareUntil(
      iter,
      openingParenthesis,
      closingParenthesis,
      closingParenthesis,
    );
    checkThis(iter, closingParenthesis, 'Expected ")"');

    var arguments = <Expression>[];
    var commaTrailing = false;
    final argIter = argumentTokens.iterator;
    while (argIter.moveNext()) {
      final tokenBuff = consumeUntil(argIter, RegExp(",\$"));
      if (tokenBuff.isEmpty) {
        if (argIter.current?.value == ',' || arguments.isNotEmpty) {
          throw SyntaxError(argIter.current, 'Expected an argument');
        } else {
          continue;
        }
      } else {
        arguments.add(Expression.parse(tokenBuff));
        commaTrailing = argIter.current?.value == ',';
      }
    }
    if (commaTrailing) {
      throw SyntaxError(argIter.current, 'Expected an argument');
    }

    return RoutineCall(routineName, arguments);
  }

  String toString({int depth = 0, String prefix = ''}) {
    return (drawDepth('${prefix}RoutineCall("${this.name}")', depth) +
        drawDepth('arguments:', depth + 1) +
        this
            .arguments
            .map((node) => node?.toString(depth: depth + 2) ?? '')
            .join(''));
  }

  Literal evaluate() {
    throw StateError("Can't evaluate a non-constant expression");
  }

  void propagateScopeMark(ScopeElement parentMark) {
    this.scopeMark = parentMark;
    for (var argument in arguments) {
      argument.propagateScopeMark(parentMark);
    }
  }

  void checkSemantics() {
    var declaration = this.scopeMark.resolve(this.name);
    if (declaration == null) {
      throw SemanticError(this, "Name ${this.name} is not defined");
    }
    if (declaration is! RoutineDeclaration) {
      throw SemanticError(this, "Can only call routines");
    }

    this.resultType = (declaration as RoutineDeclaration).returnType;
    var parameters = (declaration as RoutineDeclaration).parameters;

    if (parameters.length != this.arguments.length) {
      throw SemanticError(this,
          "Expected ${parameters.length} arguments, found ${this.arguments.length}");
    }

    for (var i = 0; i < parameters.length; ++i) {
      this.arguments[i].checkSemantics();
      if (this.arguments[i].resultType != parameters[i].type) {
        throw SemanticError(this, "Incorrect argument type");
      }
    }
  }

  Pointer<LLVMOpaqueValue> generateCode(Module module) {
    Pointer<LLVMOpaqueBasicBlock> block = null;
    if (module.isStatement) {
      module.isStatement = false;
      block = llvm.LLVMAppendBasicBlock(
          module.getLastRoutine(), MemoryManager.getCString('routine-call'));
      llvm.LLVMPositionBuilderAtEnd(module.builder, block);
      RoutineDeclaration callee = this.scopeMark.resolve(this.name);
      final args = MemoryManager.getArray(this.arguments.length)
          .cast<Pointer<LLVMOpaqueValue>>();

      for (var i = 0; i < this.arguments.length; i++) {
        args.elementAt(i).value = this.arguments[i].generateCode(module);
      }

      llvm.LLVMBuildCall2(
          module.builder,
          callee.signature,
          module.getRoutine(this.name),
          args,
          this.arguments.length,
          MemoryManager.getCString("unused"));
      return llvm.LLVMBasicBlockAsValue(block);
    } else {
      RoutineDeclaration callee = this.scopeMark.resolve(this.name);
      final args = MemoryManager.getArray(this.arguments.length)
          .cast<Pointer<LLVMOpaqueValue>>();

      for (var i = 0; i < this.arguments.length; i++) {
        args.elementAt(i).value = this.arguments[i].generateCode(module);
      }

      return llvm.LLVMBuildCall2(
          module.builder,
          callee.signature,
          module.getRoutine(this.name),
          args,
          this.arguments.length,
          MemoryManager.getCString("$name-call"));
    }
  }
}
