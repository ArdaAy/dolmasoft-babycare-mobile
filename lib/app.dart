import 'package:babycare_mobile/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';

class BabyCareApp extends StatelessWidget {
  const BabyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D5C63),
        surface: const Color(0xFFF6F8F7),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6F5),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      useMaterial3: true,
    );

    return MaterialApp(title: 'BabyCare', theme: theme, home: const AuthGate());
  }
}
