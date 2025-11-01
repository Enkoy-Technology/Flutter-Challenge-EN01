import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppImageWidget extends StatelessWidget {
  final String url;
  final bool isFromLocalAsset;
  final bool isCacheable;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? color;
  const AppImageWidget({
    super.key,
    required this.url,
    this.isFromLocalAsset = false,
    this.isCacheable = true,
    this.width = 50,
    this.height = 50,
    this.fit = BoxFit.cover,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isFromLocalAsset,
      //TODO implement cached network image
      replacement: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        color: color,
      ),
      child: Image.asset(url,
          width: width, height: height, fit: fit, color: color),
    );
  }
}
