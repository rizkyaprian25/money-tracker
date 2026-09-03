import 'package:flutter/material.dart';

/// Fallback: tampilkan placeholder icon (dipakai jika platform tak dikenal).
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
    return Icon(fallbackIcon, size: 40, color: fallbackColor);
  }
}

/// True jika ada path image yang layak ditampilkan.
/// Versi stub: selalu false agar tidak sentuh filesystem.
bool hasGoalImage(String? imagePath) => false;
