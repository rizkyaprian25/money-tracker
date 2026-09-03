import 'package:flutter/material.dart';

class AppColors {
  // Primary - Figma exact
  static const primary = Color(0xFF24389C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF3F51B5);
  static const onPrimaryContainer = Color(0xFFCACFFF);
  static const primaryFixed = Color(0xFFDEE0FF);
  static const primaryFixedDim = Color(0xFFBAC3FF);
  static const onPrimaryFixed = Color(0xFF00105C);
  static const onPrimaryFixedVariant = Color(0xFF293CA0);
  static const inversePrimary = Color(0xFFBAC3FF);

  // Secondary
  static const secondary = Color(0xFF006E1C);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF91F78E);
  static const onSecondaryContainer = Color(0xFF00731E);
  static const secondaryFixed = Color(0xFF94F990);
  static const secondaryFixedDim = Color(0xFF78DC77);
  static const onSecondaryFixed = Color(0xFF002204);
  static const onSecondaryFixedVariant = Color(0xFF005313);

  // Tertiary / Error
  static const tertiary = Color(0xFF8C0005);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFB51010);
  static const onTertiaryContainer = Color(0xFFFFC4BC);
  static const tertiaryFixed = Color(0xFFFFDAD5);
  static const tertiaryFixedDim = Color(0xFFFFB4A9);
  static const onTertiaryFixed = Color(0xFF410001);
  static const onTertiaryFixedVariant = Color(0xFF930005);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surface - Figma
  static const background = Color(0xFFF8F9FA);
  static const onBackground = Color(0xFF191C1D);
  static const surface = Color(0xFFF8F9FA);
  static const onSurface = Color(0xFF191C1D);
  static const surfaceVariant = Color(0xFFE1E3E4);
  static const onSurfaceVariant = Color(0xFF454652);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);
  static const surfaceDim = Color(0xFFD9DADB);
  static const surfaceBright = Color(0xFFF8F9FA);
  static const surfaceTint = Color(0xFF4355B9);
  static const inverseSurface = Color(0xFF2E3132);
  static const inverseOnSurface = Color(0xFFF0F1F2);
  static const outline = Color(0xFF757684);
  static const outlineVariant = Color(0xFFC5C5D4);

  static const seedColor = primary;

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    scrim: Color(0xFF000000),
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFBAC3FF),
    onPrimary: Color(0xFF00105C),
    primaryContainer: Color(0xFF293CA0),
    onPrimaryContainer: Color(0xFFDEE0FF),
    secondary: Color(0xFF78DC77),
    onSecondary: Color(0xFF00390A),
    secondaryContainer: Color(0xFF005313),
    onSecondaryContainer: Color(0xFF94F990),
    tertiary: Color(0xFFFFB4A9),
    onTertiary: Color(0xFF680003),
    tertiaryContainer: Color(0xFF930005),
    onTertiaryContainer: Color(0xFFFFDAD5),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF131314),
    onSurface: Color(0xFFE1E3E4),
    surfaceContainerHighest: Color(0xFF454652),
    onSurfaceVariant: Color(0xFFC5C5D4),
    outline: Color(0xFF8F90A0),
    outlineVariant: Color(0xFF454652),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E3E4),
    onInverseSurface: Color(0xFF2E3132),
    inversePrimary: Color(0xFF4355B9),
    surfaceTint: Color(0xFFBAC3FF),
  );
}
