import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }
}
