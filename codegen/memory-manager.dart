import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class MemoryManager {
  static List<ffi.Pointer> allocations = [];

  static ffi.Pointer<ffi.Int8> getCString(String dartString) {
    var newAllocation = Utf8.toUtf8(dartString).cast<ffi.Int8>();
    allocations.add(newAllocation);
    return newAllocation;
  }

  static ffi.Pointer<ffi.Pointer> getArray(int size) {
    var newAllocation = allocate<ffi.Pointer>(count: size);
    allocations.add(newAllocation);
    return newAllocation;
  }

  static void dispose() {
    for (var allocation in allocations) {
      free(allocation);
    }
    allocations.clear();
  }
}
