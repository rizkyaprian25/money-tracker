import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// IO (Android/desktop): copy file cache image_picker ke
/// documents/goal_images agar path tidak hilang setelah restart
/// (cache path volatile — PRD §15 Risiko, ERROR.md §2.2).
Future<String?> persistGoalImage(XFile file) async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'goal_images'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final target =
        p.join(dir.path, 'goal_${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(file.path).copy(target);
    return target;
  } catch (_) {
    return file.path;
  }
}
