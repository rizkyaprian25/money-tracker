import 'dart:io';
import 'package:flutter/material.dart';

/// Implementasi IO (Android/desktop): pakai FileImage dari path lokal.
/// Path diasumsikan sudah dipersist ke documents directory (lihat Fase 2).
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
    return Image.file(
      File(imagePath!),
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
  try {
    return File(imagePath).existsSync();
  } catch (_) {
    return false;
  }
}
