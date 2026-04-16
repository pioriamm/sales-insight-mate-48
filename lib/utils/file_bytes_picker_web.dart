import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickFileBytes({required List<String> allowedExtensions}) {
  final completer = Completer<Uint8List?>();

  final input = html.FileUploadInputElement();
  input.accept = allowedExtensions.map((ext) => '.${ext.toLowerCase()}').join(',');

  void completeOnce(Uint8List? value) {
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completeOnce(null);
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completeOnce(Uint8List.view(result));
      } else {
        completeOnce(null);
      }
    });
    reader.readAsArrayBuffer(file);
  }).catchError((_) {
    completeOnce(null);
  });

  input.click();
  return completer.future;
}
