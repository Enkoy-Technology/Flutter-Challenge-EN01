import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppImageWidget extends StatelessWidget {
  final String url;
  final bool isFromLocalAsset;
  final bool isCacheable;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  const AppImageWidget({
    super.key,
    required this.url,
    this.isFromLocalAsset = false,
    this.isCacheable = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isFromLocalAsset,
      replacement: CachedNetworkImage(
        imageUrl: url,
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
