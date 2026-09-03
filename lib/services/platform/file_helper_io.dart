import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String> saveBytes(String fileName, Uint8List bytes, {String mimeType = 'application/octet-stream'}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<Uint8List?> pickFileBytes() async => null;

Future<String> getTempFilePath(String fileName) async {
  final dir = await getTemporaryDirectory();
  return '${dir.path}/$fileName';
}

Future<String> readFileAsString(String path) async {
  return File(path).readAsString();
}

Future<void> shareFileWeb(String path) async {
  // share_plus 11: API lama Share.shareXFiles deprecated -> SharePlus.instance.
  await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
}
