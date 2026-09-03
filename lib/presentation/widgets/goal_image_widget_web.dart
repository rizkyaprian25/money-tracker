import 'package:flutter/material.dart';

/// Implementasi Web: tanpa dart:io.
/// - Jika imagePath berupa URL/blob (http/blob:/data:) tampilkan via NetworkImage.
/// - Jika path lokal Android (tidak valid di web) tampilkan placeholder icon
///   agar `flutter run -d chrome` tidak crash kompilasi (ERROR.md H1).
class GoalImageWidget extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final Color fallbackColor;
  const GoalImageWidget({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasGoalImage(imagePath)) {
      return Icon(fallbackIcon, size: 40, color: fallbackColor);
    }
    return Image.network(
      imagePath!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) =>
          Icon(fallbackIcon, size: 40, color: fallbackColor),
    );
  }
}

bool hasGoalImage(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return false;
  return imagePath.startsWith('http') ||
      imagePath.startsWith('blob:') ||
      imagePath.startsWith('data:');
}
