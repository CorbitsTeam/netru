import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/image_compression_utils.dart';
import '../../features/auth/domain/entities/identity_document_entity.dart';

/// Enhanced document scanner service that uses:
/// - cunning_document_scanner for edge detection and automatic cropping
/// - Image compression and optimization
class EnhancedDocumentScannerService {
  static const String _logTag = '📄 DocumentScanner';

  /// Scan document using camera with automatic detection and cropping
  static Future<DocumentScanResult?> scanDocument({
    DocumentType documentType = DocumentType.nationalId,
  }) async {
    try {
      print('$_logTag بدء مسح المستند باستخدام الكاميرا...');

      // Use cunning_document_scanner for better edge detection
      final scannedImage = await _scanWithCunningScanner();
      if (scannedImage == null) {
        print('$_logTag فشل في مسح المستند');
        return null;
      }

      print('$_logTag تم مسح المستند بنجاح');

      // Compress the scanned image
      final compressedImage = await _compressScannedImage(scannedImage);
      if (compressedImage == null) {
        print('$_logTag فشل في ضغط الصورة');
        return null;
      }

      return DocumentScanResult(
        imageFile: compressedImage,
        originalImageSize: await _getImageSize(scannedImage),
        compressedImageSize: await _getImageSize(compressedImage),
      );
    } catch (e) {
      print('$_logTag خطأ في مسح المستند: $e');
      return null;
    }
  }

  /// Scan document from gallery with optional edge detection
  static Future<DocumentScanResult?> scanDocumentFromGallery({
    bool applyEdgeDetection = true,
    DocumentType documentType = DocumentType.nationalId,
  }) async {
    try {
      print('$_logTag اختيار صورة من المعرض...');

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        print('$_logTag لم يتم اختيار صورة');
        return null;
      }

      File imageFile = File(pickedFile.path);

      // Apply edge detection if requested
      if (applyEdgeDetection) {
        final croppedImage = await _applyCropping(imageFile);
        if (croppedImage != null) {
          imageFile = croppedImage;
        }
      }

      // Compress the image
      final compressedImage = await _compressScannedImage(imageFile);
      if (compressedImage == null) {
        print('$_logTag فشل في ضغط الصورة');
        return null;
      }

      return DocumentScanResult(
        imageFile: compressedImage,
        originalImageSize: await _getImageSize(imageFile),
        compressedImageSize: await _getImageSize(compressedImage),
      );
    } catch (e) {
      print('$_logTag خطأ في اختيار الصورة: $e');
      return null;
    }
  }

  /// Scan multiple documents (for front and back ID cards)
  static Future<List<DocumentScanResult>> scanMultipleDocuments({
    DocumentType documentType = DocumentType.nationalId,
  }) async {
    print('$_logTag بدء مسح مستندات متعددة...');
    final List<DocumentScanResult> results = [];

    try {
      // Scan front document
      final frontResult = await scanDocument(documentType: documentType);
      if (frontResult != null) {
        results.add(frontResult);
        print('$_logTag تم مسح المستند الأمامي');
      }

      // For national ID, scan back document as well
      if (documentType == DocumentType.nationalId) {
        print('$_logTag مسح المستند الخلفي...');
        final backResult = await scanDocument(documentType: documentType);
        if (backResult != null) {
          results.add(backResult);
          print('$_logTag تم مسح المستند الخلفي');
        }
      }

      print('$_logTag تم مسح ${results.length} مستند');
      return results;
    } catch (e) {
      print('$_logTag خطأ في مسح المستندات المتعددة: $e');
      return results;
    }
  }

  /// Private method to scan using cunning_document_scanner
  static Future<File?> _scanWithCunningScanner() async {
    try {
      print('$_logTag استخدام cunning_document_scanner...');

      final scannedImages = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: false,
      );

      if (scannedImages != null && scannedImages.isNotEmpty) {
        return File(scannedImages.first);
      }

      return null;
    } catch (e) {
      print('$_logTag خطأ في cunning_document_scanner: $e');
      return null;
    }
  }

  /// Apply edge detection and cropping to an existing image
  static Future<File?> _applyCropping(File imageFile) async {
    try {
      print('$_logTag تطبيق قص الصورة...');

      // Use cunning document scanner for cropping
      final scannedImages = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
      );

      if (scannedImages != null && scannedImages.isNotEmpty) {
        return File(scannedImages.first);
      }

      return imageFile;
    } catch (e) {
      print('$_logTag خطأ في تطبيق القص: $e');
      return imageFile;
    }
  }

  /// Compress scanned image for optimal storage
  static Future<File?> _compressScannedImage(File imageFile) async {
    try {
      // Compress image to reasonable size while maintaining quality
      final compressedImage = await ImageCompressionUtils.compressImage(
        imageFile,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (compressedImage != null) {
        // Ensure the compressed image is under 2MB for better performance
        final sizeKB = await ImageCompressionUtils.getImageSizeKB(
          compressedImage,
        );
        if (sizeKB > 2048) {
          return await ImageCompressionUtils.compressImageToSize(
            compressedImage,
            targetSizeKB: 1024,
            maxWidth: 1600,
            maxHeight: 1600,
          );
        }
        return compressedImage;
      }

      return imageFile;
    } catch (e) {
      print('$_logTag خطأ في ضغط الصورة: $e');
      return imageFile;
    }
  }

  /// Get image file size in KB
  static Future<double> _getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / 1024;
    } catch (e) {
      return 0;
    }
  }

  /// Clean up temporary files
  static Future<void> cleanup() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles =
          tempDir
              .listSync()
              .where((file) => file.path.contains('scanner_'))
              .cast<File>();

      for (final file in tempFiles) {
        try {
          await file.delete();
        } catch (e) {
          print('$_logTag خطأ في حذف الملف: $e');
        }
      }

      print('$_logTag تم تنظيف ${tempFiles.length} ملف مؤقت');
    } catch (e) {
      print('$_logTag خطأ في تنظيف الملفات المؤقتة: $e');
    }
  }
}

/// Document scan result containing the processed image
class DocumentScanResult {
  final File imageFile;
  final double originalImageSize;
  final double compressedImageSize;

  DocumentScanResult({
    required this.imageFile,
    required this.originalImageSize,
    required this.compressedImageSize,
  });

  double get compressionRatio {
    if (originalImageSize == 0) return 0;
    return ((compressedImageSize - originalImageSize) / originalImageSize) *
        100;
  }
}
