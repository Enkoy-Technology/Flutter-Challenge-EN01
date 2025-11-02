import 'dart:async';

import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatefulWidget {
  final String message;
  const ErrorMessageWidget({super.key, required this.message});

  @override
  State<ErrorMessageWidget> createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  int animationSpeed = 1500; //1.5 secs

  int stayDuration = 3500;

  Timer? timer;

  @override
  initState() {
    super.initState();
    // _animationController = AnimationController()
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.fastEaseInToSlowEaseOut));
    _animationController!.forward();
    Future.delayed(Duration(milliseconds: stayDuration), () {
      _animationController?.reverse();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animation == null) {
      return Container();
    }
    return SizeTransition(
      sizeFactor: _animation!,
      child: Container(
        width: kdScreenWidth(context),
        decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.errorContainer.withOpacity(0.8)),
        padding: const EdgeInsets.all(kdPaddingLarge),
        child: Row(
          children: [
            Icon(
              kiError,
              color: kcOnErrorContainer(context),
            ),
            kdSpace.width,
            SizedBox(
              width: kdScreenWidth(context) * .72,
              child: Text(
                widget.message,
                style: kfBodyMedium(context,
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
