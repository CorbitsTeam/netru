import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility class for image compression and processing
class ImageCompressionUtils {
  /// Compress image file with specified quality and dimensions
  static Future<File?> compressImage(
    File imageFile, {
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final extension = path.extension(imageFile.path);
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_compressed${extension.isEmpty ? '.jpg' : extension}',
      );

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      return compressedXFile != null ? File(compressedXFile.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Compress image to specific size in KB
  static Future<File?> compressImageToSize(
    File imageFile, {
    int targetSizeKB = 500,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(tempDir.path, '${fileName}_compressed.jpg');

      // Start with high quality and reduce if needed
      int quality = 95;
      File? compressedFile;

      while (quality >= 20) {
        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          targetPath,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
          format: CompressFormat.jpeg,
        );

        if (compressedXFile != null) {
          compressedFile = File(compressedXFile.path);
          final sizeKB = await compressedFile.length() / 1024;

          if (sizeKB <= targetSizeKB) {
            return compressedFile;
          }
        }

        quality -= 10;
      }

      return compressedFile;
    } catch (e) {
      print('Error compressing image to size: $e');
      return null;
    }
  }

  /// Compress image to Uint8List for memory usage
  static Future<Uint8List?> compressImageToBytes(
    File imageFile, {
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      return compressedBytes;
    } catch (e) {
      print('Error compressing image to bytes: $e');
      return null;
    }
  }

  /// Resize image to specific dimensions while maintaining aspect ratio
  static Future<File?> resizeImage(
    File imageFile, {
    required int width,
    required int height,
    int quality = 85,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(tempDir.path, '${fileName}_resized.jpg');

      final resizedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: width,
        minHeight: height,
        format: CompressFormat.jpeg,
      );

      return resizedXFile != null ? File(resizedXFile.path) : null;
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  /// Get image file size in KB
  static Future<double> getImageSizeKB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / 1024;
    } catch (e) {
      return 0;
    }
  }

  /// Check if image needs compression based on size
  static Future<bool> needsCompression(
    File imageFile, {
    int maxSizeKB = 1024,
  }) async {
    final sizeKB = await getImageSizeKB(imageFile);
    return sizeKB > maxSizeKB;
  }

  /// Create thumbnail from image
  static Future<File?> createThumbnail(
    File imageFile, {
    int size = 200,
    int quality = 70,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(tempDir.path, '${fileName}_thumb.jpg');

      final thumbnailXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: size,
        minHeight: size,
        format: CompressFormat.jpeg,
      );

      return thumbnailXFile != null ? File(thumbnailXFile.path) : null;
    } catch (e) {
      print('Error creating thumbnail: $e');
      return null;
    }
  }
}
