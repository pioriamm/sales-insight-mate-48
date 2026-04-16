import 'dart:typed_data';

import 'file_bytes_picker_native.dart'
    if (dart.library.html) 'file_bytes_picker_web.dart' as picker_impl;

Future<Uint8List?> pickFileBytes({required List<String> allowedExtensions}) {
  return picker_impl.pickFileBytes(allowedExtensions: allowedExtensions);
}
