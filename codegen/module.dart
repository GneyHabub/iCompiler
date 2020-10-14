import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'memory-manager.dart';
import 'llvm.dart';
import '../ast-nodes/index.dart';
import '../utils/index.dart';

String getLlvmPath() {
  if (Platform.isLinux) {
    return '/usr/lib/libLLVM-10.so';
  } else if (Platform.isMacOS) {
    return '/usr/local/Cellar/llvm/10.0.1_1/lib/libLLVM.dylib';
  } else if (Platform.isWindows) {
    return 'C:/Program Files/LLVM/bin/LLVM-C.dll';
  }
  throw Exception('Platform not supported');
}

final llvm = LLVM(DynamicLibrary.open(getLlvmPath()));


/// A wrapper around the LLVM Module for easier use.
class Module {
  Pointer<LLVMOpaqueContext> context;
  Pointer<LLVMOpaqueBuilder> builder;
  Pointer<LLVMOpaqueModule> _module;
  Pointer<LLVMOpaqueType> printfSignature;
  Pointer<LLVMOpaqueType> strcmpSignature;
  Pointer<LLVMOpaqueValue> printf;
  Pointer<LLVMOpaqueValue> strcmp;
  bool isGlobal = true;
  bool isStatement = false;

  var LLVMValuesStorage = new Map();

  Module(String name) {
    this.context = llvm.LLVMContextCreate();
    this._module = llvm.LLVMModuleCreateWithNameInContext(
      MemoryManager.getCString(name),
      this.context,
    );
    this.builder = llvm.LLVMCreateBuilderInContext(this.context);

    printfSignature = getPrintfSignature(this);
    printf = this.addRoutine('printf', printfSignature);
    strcmpSignature = getStrcmpSignature(this);
    strcmp = this.addRoutine('strcmp', strcmpSignature);
  }

  Pointer<LLVMOpaqueValue> addRoutine(String name, Pointer<LLVMOpaqueType> type) {
    return llvm.LLVMAddFunction(this._module, MemoryManager.getCString(name), type);
  }

  Pointer<LLVMOpaqueValue> getLastRoutine() {
    return llvm.LLVMGetLastFunction(this._module);
  }

  Pointer<LLVMOpaqueValue> getRoutine(String name) {
    return llvm.LLVMGetNamedFunction(this._module, MemoryManager.getCString(name));
  }

  Pointer<LLVMOpaqueValue> addGlobalVariable(String name, VarType type, Expression value) {
    var resolvedType = type.resolve();
    var variable = llvm.LLVMAddGlobal(
        this._module,
        resolvedType.getLlvmType(this),
        MemoryManager.getCString(name));
    if (resolvedType is IntegerType) {
      llvm.LLVMSetInitializer(variable, llvm.LLVMConstInt(
        resolvedType.getLlvmType(this),
        value.evaluate().integerValue,
        1,  // SignExtend: true
      ));
    } else if (resolvedType is BooleanType) {
      llvm.LLVMSetInitializer(variable, llvm.LLVMConstInt(
        resolvedType.getLlvmType(this),
        value.evaluate().integerValue,
        0,  // SignExtend: false
      ));
    } else if (resolvedType is RealType) {
      llvm.LLVMSetInitializer(variable, llvm.LLVMConstReal(
        resolvedType.getLlvmType(this),
        value.evaluate().realValue,
      ));
    }
    return variable;
  }

  /// Get the string representation of the module.
  ///
  /// This includes metadata like the name as well as the instruction dump.
  String toString() {
    var stringPtr = llvm.LLVMPrintModuleToString(this._module);
    var representation = Utf8.fromUtf8(stringPtr.cast<Utf8>());
    llvm.LLVMDisposeMessage(stringPtr);
    return representation;
  }

  void validate() {
    Pointer<Pointer<Int8>> error = allocate<Pointer<Int8>>(count: 1);
    error.value = nullptr;
    llvm.LLVMVerifyModule(this._module, LLVMVerifierFailureAction.LLVMAbortProcessAction, error);
    llvm.LLVMDisposeMessage(error.value);
  }

  void dumpBitcode(String filename) {
    if (llvm.LLVMWriteBitcodeToFile(this._module, MemoryManager.getCString(filename)) != 0) {
      throw StateError('Failed to write bitcode to \'$filename\'');
    }
  }

  /// Free the memory occupied by this module.
  void dispose() {
    llvm.LLVMDisposeModule(this._module);
    llvm.LLVMDisposeBuilder(this.builder);
    llvm.LLVMContextDispose(this.context);
  }
}
