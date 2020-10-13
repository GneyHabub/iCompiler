import 'dart:ffi';
import '../codegen/index.dart';

/// Returns the signature of the entrypoint function.
///
/// The C equivalent of the signature is:
/// ```c
/// int entrypoint(int argc, char **argv);
/// ```
Pointer<LLVMOpaqueType> getEntrypointSignature(Module module) {
  var parameterAmount = 2;
  var paramTypes =
      MemoryManager.getArray(parameterAmount).cast<Pointer<LLVMOpaqueType>>();
  paramTypes.elementAt(0).value = llvm.LLVMInt32TypeInContext(module.context);
  paramTypes.elementAt(1).value = llvm.LLVMPointerType(
    llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0), 0
  );

  return llvm.LLVMFunctionType(
    llvm.LLVMInt32TypeInContext(module.context),
    paramTypes,
    parameterAmount,
    0, // IsVariadic: false
  );
}

/// Returns the signature of the `strcmp` function of string.h in C standard library.
///
/// The C equivalent of the signature is:
/// ```c
/// int strcmp(char **str1, char **str2);
/// ```
Pointer<LLVMOpaqueType> getStrcmpSignature(Module module) {
  var parameterAmount = 2;
  var paramTypes =
      MemoryManager.getArray(parameterAmount).cast<Pointer<LLVMOpaqueType>>();
  paramTypes.elementAt(0).value =
      llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0);
  paramTypes.elementAt(1).value =
      llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0);

  return llvm.LLVMFunctionType(
    llvm.LLVMInt32TypeInContext(module.context),
    paramTypes,
    parameterAmount,
    0, // IsVariadic: false
  );
}

/// Returns the signature of the `printf` function of stdio.h in C standard library.
///
/// The C equivalent of the signature is:
/// ```c
/// int printf(char **format);
/// ```
Pointer<LLVMOpaqueType> getPrintfSignature(Module module) {
  var parameterAmount = 1;
  var paramTypes =
      MemoryManager.getArray(parameterAmount).cast<Pointer<LLVMOpaqueType>>();
  paramTypes.elementAt(0).value =
      llvm.LLVMPointerType(llvm.LLVMInt8TypeInContext(module.context), 0);

  return llvm.LLVMFunctionType(
    llvm.LLVMInt32TypeInContext(module.context),
    paramTypes,
    parameterAmount,
    1, // IsVariadic: true
  );
}
