// Theme configuration for Elif-Ba Ses Eğitimi application.
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(centerTitle: true),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
