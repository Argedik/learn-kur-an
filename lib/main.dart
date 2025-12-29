// Entry point for the Elif-Ba Ses Eğitimi MVP application.
import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'features/recorder/recorder_page.dart';

void main() {
  runApp(const ElifBaApp());
}

class ElifBaApp extends StatelessWidget {
  const ElifBaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elif-Ba Ses Eğitimi',
      theme: AppTheme.light,
      home: const RecorderPage(),
    );
  }
}
