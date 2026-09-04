import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

// Web implementation: trigger browser download via anchor element.
Future<String> saveBytes(String fileName, Uint8List bytes, {String mimeType = 'application/octet-stream'}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  // Append to body, click, then remove
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  // On web we return fileName as pseudo-path for UI feedback
  return fileName;
}

Future<Uint8List?> pickFileBytes() async => null;

Future<String> getTempFilePath(String fileName) async => fileName;

Future<String> readFileAsString(String path) async {
  throw UnsupportedError('readFileAsString with path not supported on web; use bytes');
}

Future<void> shareFileWeb(String path) async {
  // On web, file already downloaded via saveBytes, nothing to share
}

/// Web: tanpa filesystem — backup pengaman restore tidak didukung.
Future<String> saveAutoBackup(String fileName, Uint8List bytes, {String mimeType = 'application/octet-stream'}) async => '';
