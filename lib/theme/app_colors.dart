import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryGradientStart = Color.fromARGB(255, 202, 120, 216);
  static const Color primaryGradientEnd = Color.fromARGB(255, 67, 142, 203); 
  static const Color primaryBlue = Color(0xFF2196F3); 
  static const Color deepPurple = Color(0xFF8E24AA);

  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
  static const Color lightGreyBackground = Color(0xFFF5F5F5);

  static const Color black87 = Colors.black87; 
  static const Color greyText = Color(0xFF9E9E9E); 
  static const Color greyTextDark = Color(0xFF757575); 
  static const Color blueGreyText = Color(0xFF607D8B);
  static const Color lightPinkText =
      Color(0xFFF8E6FB); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color lightBlueAccent = Colors.lightBlueAccent;

  static const Color grey = Colors.grey;
  static const Color shadowColor =
      Color(0x0C000000);

  static const LightColors light = LightColors();

  static const DarkColors dark = DarkColors();
}

class LightColors {
  const LightColors();

  Color get primaryGradientStart => const Color(0xFF43CEA2);
  Color get primaryGradientEnd => const Color(0xFF185A9D);
  Color get primaryBlue => const Color.fromARGB(255, 3, 65, 171);
  Color get deepPurple => const Color(0xFF8F5CFF);

  Color get background => const Color(0xFFF8FAFC);
  Color get surface => const Color(0xFFFFFFFF);
  Color get lightGreyBackground => const Color(0xFFF1F3F6);
  Color get transparent => Colors.transparent;

  Color get textPrimary => const Color(0xFF22223B);
  Color get textSecondary => const Color(0xFF5C5F6E);
  Color get textTertiary => const Color(0xFFB6BBC4);
  Color get textBlueGrey => const Color(0xFF77A5C2);
  Color get textLightPink => const Color(0xFFFFB7C5);
  Color get textOnPrimary => Colors.white;
  Color get textOnPrimary70 => Colors.white70;

  Color get online => const Color(0xFF51D88A);
  Color get offline => const Color(0xFFCFD8DC);
  Color get error => const Color(0xFFF44336);
  Color get success => const Color(0xFF4CAF50);
  Color get readStatus => const Color(0xFF54D1DB);
  Color get deliveredStatus => const Color(0xFFB2F5EA);
  Color get sentStatus => const Color(0xFFA3CEF1);

  Color get avatarBackground => const Color(0xFFE4ECFA);
  Color get avatarBorder => Colors.white;
  Color get shadow => const Color(0x14223E50);
  Color get divider => const Color(0xFFEDEFFD);
  Color get inputFill => const Color(0xFFFEFEFF);
  Color get buttonBackground => const Color(0xFF43CEA2);
  Color get buttonForeground => Colors.white;
}


class DarkColors {
  const DarkColors();

  Color get primaryGradientStart =>
      const Color(0xFF6A1B9A); 
  Color get primaryGradientEnd =>
      const Color(0xFF1976D2);
  Color get primaryBlue =>
      const Color(0xFF42A5F5); 
  Color get deepPurple =>
      const Color(0xFFAB47BC);

  Color get background => const Color(0xFF121212);
  Color get surface => const Color(0xFF1E1E1E); 
  Color get lightGreyBackground =>
      const Color(0xFF2C2C2C);
  Color get transparent => AppColors.transparent;

  Color get textPrimary => Colors.white;
  Color get textSecondary => const Color(0xFFB0B0B0); 
  Color get textTertiary => const Color(0xFF757575); 
  Color get textBlueGrey => const Color(0xFF90A4AE); 
  Color get textLightPink =>
      const Color(0xFFE1BEE7);
  Color get textOnPrimary => Colors.white;
  Color get textOnPrimary70 => Colors.white70;

  Color get online => const Color(0xFF4CAF50); 
  Color get offline => const Color(0xFF757575); 
  Color get error => const Color(0xFFEF5350); 
  Color get success => const Color(0xFF4CAF50); 
  Color get readStatus => const Color(0xFF64B5F6); 
  Color get deliveredStatus => const Color(0xFFB0BEC5);
  Color get sentStatus => const Color(0xFFB0BEC5);

  Color get avatarBackground => const Color(0xFF7B1FA2); 
  Color get avatarBorder => const Color(0xFF424242); 
  Color get shadow => const Color(0x40000000); 
  Color get divider => const Color(0xFF424242); 
  Color get inputFill => const Color(0xFF2C2C2C);
  Color get buttonBackground =>
      const Color(0xFF2C2C2C);
  Color get buttonForeground =>
      const Color(0xFF64B5F6); 
}
