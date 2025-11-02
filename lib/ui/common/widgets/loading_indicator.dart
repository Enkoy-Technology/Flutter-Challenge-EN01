import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final int? progress;
  final Color? color;
  final double size;
  final bool withBackground;
  const LoadingIndicator(
      {super.key,
      this.progress,
      this.size = 50,
      this.withBackground = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        if (withBackground)
          Container(
            color: kcBackground(context).withOpacity(0.5),
            height: size,
            width: size,
            child: SpinKitCircle(
              color: color ??
                  (isDarkMode
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).primaryColor),
              size: size,
            ),
          ),
        if (!withBackground)
          SpinKitCircle(
            color: color ??
                (isDarkMode
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).primaryColor),
            size: size,
          ),
        if (progress != null)
          Positioned.fill(
              child: Align(
            alignment: Alignment.center,
            child: Text(
              "$progress%",
              style: bodyStyle.copyWith(color: color, fontSize: kfSmall),
            ),
          ))
      ],
    );
  }
}
