import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';



class ClickableTextSpan extends StatefulWidget {
  final String mainText;
  final String clickableText;
  final TextStyle mainTextStyle;
  final TextStyle clickableTextStyle;
  final VoidCallback onTap;
  final String? trailingText;
  final TextStyle? trailingTextStyle;

  const ClickableTextSpan({
    super.key,
    required this.mainText,
    required this.clickableText,
    required this.mainTextStyle,
    required this.clickableTextStyle,
    required this.onTap,
    this.trailingText,
    this.trailingTextStyle,
  });

  @override
  State<ClickableTextSpan> createState() => _ClickableTextSpanState();
}

class _ClickableTextSpanState extends State<ClickableTextSpan> {
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.mainText,
        style: widget.mainTextStyle,
        children: [
          TextSpan(
            text: widget.clickableText,
            style: widget.clickableTextStyle,
            recognizer: _tapGestureRecognizer,
          ),
          if (widget.trailingText != null)
            TextSpan(
              text: widget.trailingText,
              style: widget.trailingTextStyle ?? widget.mainTextStyle,
            ),
        ],
      ),
    );
  }
}
