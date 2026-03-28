import 'package:flutter/material.dart';

/// Tema global de la aplicación MilOjos
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.red,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.red,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
