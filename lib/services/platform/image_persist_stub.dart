import 'package:image_picker/image_picker.dart';

/// Fallback: kembalikan path asli tanpa copy.
Future<String?> persistGoalImage(XFile file) async => file.path;
