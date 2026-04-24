import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1A2D42);
  static const Color surfaceLight = Color(0xFF243850);
  static const Color accent = Color(0xFF4FC3F7);
  static const Color accentDark = Color(0xFF0288D1);
  static const Color white = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color buttonPrimary = Color(0xFF4FC3F7);
  static const Color buttonSecondary = Color(0xFF1E3A50);
  static const Color danger = Color(0xFFEF5350);

  // Player colors
  static const Color player1 = Color(0xFFEF5350); // Red
  static const Color player2 = Color(0xFF26A69A); // Teal
  static const Color player3 = Color(0xFF7E57C2); // Purple
  static const Color player4 = Color(0xFFFFA726); // Orange
  static const Color playerSelf = Color(0xFF7E57C2); // Purple (you)
}

class AppTextStyles {
  static const String fontFamily = 'Rajdhani';

  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 2,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.white,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 1.5,
  );
}
