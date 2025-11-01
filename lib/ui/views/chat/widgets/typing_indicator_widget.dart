import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TypingIndicatorWidget extends StatelessWidget {
  const TypingIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SpinKitThreeBounce(
          color: kcPrimary(context),
          size: 10,
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          "typing",
          style: kfLabelSmall(context, color: kcPrimary(context)),
        )
      ],
    );
  }
}
