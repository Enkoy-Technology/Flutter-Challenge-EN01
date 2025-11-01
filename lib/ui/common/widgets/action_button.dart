import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final dynamic onPressed;
  final Widget child;
  final Color? backgroundColor;
  const AppActionButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: backgroundColor != null
            ? MaterialStateProperty.all<Color>(backgroundColor!)
            : null, // Change this to your desired color
      ),
      child: child,
    );
  }
}
