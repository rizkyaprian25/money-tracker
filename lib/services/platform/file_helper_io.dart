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

/// Backup pengaman otomatis sebelum restore (hanya IO).
/// Disimpan di documents/auto_backups, 3 file terbaru dipertahankan.
/// Kembalikan path file, atau '' bila gagal.
Future<String> saveAutoBackup(String fileName, Uint8List bytes) async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/auto_backups');
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    final files = (await dir.list().toList()).whereType<File>().toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in files.skip(3)) {
      try {
        await old.delete();
      } catch (_) {}
    }
    return file.path;
  } catch (_) {
    return '';
  }
}
