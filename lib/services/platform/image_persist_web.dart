import 'package:image_picker/image_picker.dart';

/// Web: tanpa filesystem — kembalikan path/blob URL asli.
/// goal_image_widget_web hanya render http/blob:/data: URL,
/// selain itu tampil placeholder (tidak crash).
Future<String?> persistGoalImage(XFile file) async => file.path;
