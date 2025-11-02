import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TypingIndicatorWidget extends StatelessWidget {
  final Color? color;
  const TypingIndicatorWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SpinKitThreeBounce(
          color: color ?? kcOnPrimary(context),
          size: 10,
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          "typing",
          style: kfLabelSmall(context, color: color ?? kcOnPrimary(context)),
        )
      ],
    );
  }
}
