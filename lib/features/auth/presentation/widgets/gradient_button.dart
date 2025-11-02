import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final isEnabled = onPressed != null;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: isEnabled ? Colors.white : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
