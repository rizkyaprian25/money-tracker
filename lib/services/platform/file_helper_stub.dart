import 'dart:typed_data';

Future<String> saveBytes(String fileName, Uint8List bytes, {String mimeType = 'application/octet-stream'}) async {
  throw UnsupportedError('Platform file_helper not implemented');
}

Future<Uint8List?> pickFileBytes() async => null;

Future<String> getTempFilePath(String fileName) async => fileName;

Future<String> readFileAsString(String path) async => throw UnsupportedError('readFileAsString not supported');

Future<void> shareFileWeb(String path) async {}

Future<String> saveAutoBackup(String fileName, Uint8List bytes, {String mimeType = 'application/octet-stream'}) async => '';
