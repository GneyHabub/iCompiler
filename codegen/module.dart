import 'dart:ffi';
import 'memory-manager.dart';
import 'package:ffi/ffi.dart';
import 'llvm.dart';

final llvm = LLVM(DynamicLibrary.open('/usr/lib/libLLVM-10.so'));

/// A wrapper around the LLVM Module for easier use.
class Module {
  Pointer<LLVMOpaqueContext> context;
  Pointer<LLVMOpaqueModule> _module;

  Module(String name) {
    this.context = llvm.LLVMContextCreate();
    this._module = llvm.LLVMModuleCreateWithNameInContext(
      MemoryManager.getCString(name),
      this.context,
    );
  }

  Pointer<LLVMOpaqueValue> addRoutine(String name, Pointer<LLVMOpaqueType> type) {
    return llvm.LLVMAddFunction(this._module, MemoryManager.getCString(name), type);
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

  /// Free the memory occupied by this module.
  void dispose() {
    llvm.LLVMDisposeModule(this._module);
    llvm.LLVMContextDispose(this.context);
  }
}
