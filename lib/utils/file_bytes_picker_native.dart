import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<Uint8List?> pickFileBytes({required List<String> allowedExtensions}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    withData: true,
  );

  return result?.files.single.bytes;
}
