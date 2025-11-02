import 'package:flutter/material.dart';

class ThemeHelper {
  static Color getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.scaffoldBackgroundColor;
  }

  static Color getSurfaceColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface;
  }

  static Color getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.onBackground;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  static Color getCardColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface;
  }

  static Color getBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;
  }

  static bool isDarkMode(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  static Color getShadowColor(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return brightness == Brightness.dark
        ? Colors.black54
        : Colors.black.withOpacity(0.05);
  }
}

