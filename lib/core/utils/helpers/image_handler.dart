import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageHandler {
  const ImageHandler._();

  static Widget image(
    String path, {
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size ?? width,
        height: size ?? height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    } else if (path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg')) {
      return Image.asset(
        path,
        width: size ?? width,
        height: size ?? height,
        fit: fit,
        color: color,
      );
    } else {
      throw UnsupportedError('Unsupported image format: $path');
    }
  }
}
