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
    try {
      if (path.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          width: size ?? width,
          height: size ?? height,
          fit: fit,
          colorFilter:
              color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
          placeholderBuilder:
              (BuildContext context) => Container(
                width: size ?? width ?? 24,
                height: size ?? height ?? 24,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
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
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size ?? width ?? 24,
              height: size ?? height ?? 24,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      } else {
        throw UnsupportedError('Unsupported image format: $path');
      }
    } catch (e) {
      // Fallback widget in case of any rendering error
      return Container(
        width: size ?? width ?? 24,
        height: size ?? height ?? 24,
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}
