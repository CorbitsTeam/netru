// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cunning_document_scanner/cunning_document_scanner.dart';
// import 'package:path_provider/path_provider.dart';
// import '../utils/image_compression_utils.dart';
// import '../../features/auth/domain/entities/extracted_document_data.dart';
// import '../../features/auth/domain/entities/identity_document_entity.dart';
//
// /// Enhanced document scanner service that combines:
// /// - Edge detection and automatic cropping
// /// - Image compression and optimization
// /// - OCR text extraction with Arabic/English support
// class EnhancedDocumentScannerService {
//   static const String _logTag = '📄 DocumentScanner';
//
//   /// Scan document using camera with automatic detection and cropping
//   static Future<DocumentScanResult?> scanDocument({
//     DocumentType documentType = DocumentType.nationalId,
//   }) async {
//     try {
//       print('$_logTag بدء مسح المستند باستخدام الكاميرا...');
//
//       // Use cunning_document_scanner for better edge detection
//       final scannedImage = await _scanWithCunningScanner();
//       if (scannedImage == null) {
//         print('$_logTag فشل في مسح المستند');
//         return null;
//       }
//
//       print('$_logTag تم مسح المستند بنجاح');
//
//       // Compress the scanned image
//       final compressedImage = await _compressScannedImage(scannedImage);
//       if (compressedImage == null) {
//         print('$_logTag فشل في ضغط الصورة');
//         return null;
//       }
//
//       // Extract text using OCR
//       final extractedData = await _extractTextFromDocument(
//         compressedImage,
//         documentType,
//       );
//
//       return DocumentScanResult(
//         imageFile: compressedImage,
//         extractedData: extractedData,
//         originalImageSize: await _getImageSize(scannedImage),
//         compressedImageSize: await _getImageSize(compressedImage),
//       );
//     } catch (e) {
//       print('$_logTag خطأ في مسح المستند: $e');
//       return null;
//     }
//   }
//
//   /// Scan document from gallery with optional edge detection
//   static Future<DocumentScanResult?> scanDocumentFromGallery({
//     bool applyEdgeDetection = true,
//     DocumentType documentType = DocumentType.nationalId,
//   }) async {
//     try {
//       print('$_logTag اختيار صورة من المعرض...');
//
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1920,
//         imageQuality: 90,
//       );
//
//       if (pickedFile == null) {
//         print('$_logTag لم يتم اختيار صورة');
//         return null;
//       }
//
//       File imageFile = File(pickedFile.path);
//
//       // Apply edge detection if requested
//       if (applyEdgeDetection) {
//         final croppedImage = await _applyCropping(imageFile);
//         if (croppedImage != null) {
//           imageFile = croppedImage;
//         }
//       }
//
//       // Compress the image
//       final compressedImage = await _compressScannedImage(imageFile);
//       if (compressedImage == null) {
//         print('$_logTag فشل في ضغط الصورة');
//         return null;
//       }
//
//       // Extract text using OCR
//       final extractedData = await _extractTextFromDocument(
//         compressedImage,
//         documentType,
//       );
//
//       return DocumentScanResult(
//         imageFile: compressedImage,
//         extractedData: extractedData,
//         originalImageSize: await _getImageSize(imageFile),
//         compressedImageSize: await _getImageSize(compressedImage),
//       );
//     } catch (e) {
//       print('$_logTag خطأ في اختيار الصورة: $e');
//       return null;
//     }
//   }
//
//   /// Scan multiple documents (for front and back ID cards)
//   static Future<List<DocumentScanResult>> scanMultipleDocuments({
//     DocumentType documentType = DocumentType.nationalId,
//   }) async {
//     print('$_logTag بدء مسح مستندات متعددة...');
//     final List<DocumentScanResult> results = [];
//
//     try {
//       // Scan front document
//       final frontResult = await scanDocument(documentType: documentType);
//       if (frontResult != null) {
//         results.add(frontResult);
//         print('$_logTag تم مسح المستند الأمامي');
//       }
//
//       // For national ID, scan back document as well
//       if (documentType == DocumentType.nationalId) {
//         print('$_logTag مسح المستند الخلفي...');
//         final backResult = await scanDocument(documentType: documentType);
//         if (backResult != null) {
//           results.add(backResult);
//           print('$_logTag تم مسح المستند الخلفي');
//         }
//       }
//
//       print('$_logTag تم مسح ${results.length} مستند');
//       return results;
//     } catch (e) {
//       print('$_logTag خطأ في مسح المستندات المتعددة: $e');
//       return results;
//     }
//   }
//
//   /// Private method to scan using cunning_document_scanner
//   static Future<File?> _scanWithCunningScanner() async {
//     try {
//       print('$_logTag استخدام cunning_document_scanner...');
//
//       final scannedImages = await CunningDocumentScanner.getPictures(
//         isGalleryImportAllowed: false,
//       );
//
//       if (scannedImages != null && scannedImages.isNotEmpty) {
//         return File(scannedImages.first);
//       }
//
//       return null;
//     } catch (e) {
//       print('$_logTag خطأ في cunning_document_scanner: $e');
//       return null;
//     }
//   }
//
//   /// Apply edge detection and cropping to an existing image
//   static Future<File?> _applyCropping(File imageFile) async {
//     try {
//       print('$_logTag تطبيق قص الصورة...');
//
//       // Use cunning document scanner for cropping
//       final scannedImages = await CunningDocumentScanner.getPictures(
//         isGalleryImportAllowed: true,
//       );
//
//       if (scannedImages != null && scannedImages.isNotEmpty) {
//         return File(scannedImages.first);
//       }
//
//       return imageFile;
//     } catch (e) {
//       print('$_logTag خطأ في تطبيق القص: $e');
//       return imageFile;
//     }
//   }
//
//   /// Compress scanned image for optimal storage and processing
//   static Future<File?> _compressScannedImage(File imageFile) async {
//     try {
//       // Compress image to reasonable size for OCR while maintaining quality
//       final compressedImage = await ImageCompressionUtils.compressImage(
//         imageFile,
//         quality: 85,
//         maxWidth: 1920,
//         maxHeight: 1920,
//       );
//
//       if (compressedImage != null) {
//         // Ensure the compressed image is under 2MB for better performance
//         final sizeKB = await ImageCompressionUtils.getImageSizeKB(
//           compressedImage,
//         );
//         if (sizeKB > 2048) {
//           return await ImageCompressionUtils.compressImageToSize(
//             compressedImage,
//             targetSizeKB: 1024,
//             maxWidth: 1600,
//             maxHeight: 1600,
//           );
//         }
//         return compressedImage;
//       }
//
//       return imageFile;
//     } catch (e) {
//       print('$_logTag خطأ في ضغط الصورة: $e');
//       return imageFile;
//     }
//   }
//
//   /// Extract text from document using OCR
//   // static Future<ExtractedDocumentData?> _extractTextFromDocument(
//   //   File imageFile,
//   //   DocumentType documentType,
//   // ) async {
//   //   try {
//   //     print('$_logTag بدء استخراج النص...');
//   //
//   //     // Extract text using Tesseract OCR with Arabic and English support
//   //     final String extractedText = await TesseractOcr.extractText(
//   //       imageFile.path,
//   //     );
//   //
//   //     print('$_logTag النص المستخرج: $extractedText');
//   //
//   //     if (extractedText.trim().isEmpty) {
//   //       print('$_logTag لم يتم استخراج أي نص');
//   //       return null;
//   //     }
//   //
//   //     // Parse the extracted text based on document type
//   //     return _parseExtractedText(extractedText, documentType);
//   //   } catch (e) {
//   //     print('$_logTag خطأ في استخراج النص: $e');
//   //     return null;
//   //   }
//   // }
//
//   /// Parse extracted text based on document type
//   static ExtractedDocumentData? _parseExtractedText(
//     String text,
//     DocumentType documentType,
//   ) {
//     try {
//       switch (documentType) {
//         case DocumentType.nationalId:
//           return _parseNationalIdText(text);
//         case DocumentType.passport:
//           return _parsePassportText(text);
//       }
//     } catch (e) {
//       print('$_logTag خطأ في تحليل النص: $e');
//       return null;
//     }
//   }
//
//   /// Parse Egyptian National ID text
//   static ExtractedDocumentData? _parseNationalIdText(String text) {
//     try {
//       final Map<String, String?> data = {};
//
//       // Extract 14-digit national ID
//       final nationalIdRegex = RegExp(r'\b\d{14}\b');
//       final nationalIdMatch = nationalIdRegex.firstMatch(text);
//       if (nationalIdMatch != null) {
//         data['nationalId'] = nationalIdMatch.group(0);
//         print('$_logTag تم استخراج الرقم القومي: ${data['nationalId']}');
//       }
//
//       // Extract Arabic name (longest Arabic text sequence)
//       final arabicNameRegex = RegExp(r'[\u0600-\u06FF\s]+');
//       final arabicMatches = arabicNameRegex.allMatches(text);
//
//       String? longestArabicText;
//       int maxLength = 0;
//
//       // Safely iterate through matches - allMatches() returns an Iterable, never null
//       for (final match in arabicMatches) {
//         final arabicText = match.group(0)?.trim();
//         if (arabicText != null &&
//             arabicText.length > maxLength &&
//             arabicText.length > 10 &&
//             arabicText.split(' ').length >= 2) {
//           maxLength = arabicText.length;
//           longestArabicText = arabicText;
//         }
//       }
//
//       if (longestArabicText != null) {
//         data['fullName'] = _cleanArabicText(longestArabicText);
//         print('$_logTag تم استخراج الاسم: ${data['fullName']}');
//       }
//
//       // Extract date from national ID if available
//       if (data['nationalId'] != null) {
//         final birthDate = _extractDateFromNationalId(data['nationalId']!);
//         if (birthDate != null) {
//           data['birthDate'] = birthDate;
//           print('$_logTag تم استخراج تاريخ الميلاد: $birthDate');
//         }
//       }
//
//       // Extract address (text containing address keywords)
//       final addressKeywords = ['محافظة', 'مركز', 'قسم', 'شارع', 'حي', 'مدينة'];
//       final lines = text.split('\n');
//
//       for (final line in lines) {
//         final cleanLine = line.trim();
//         if (cleanLine.length > 10 &&
//             addressKeywords.any((keyword) => cleanLine.contains(keyword))) {
//           data['address'] = _cleanArabicText(cleanLine);
//           print('$_logTag تم استخراج العنوان: ${data['address']}');
//           break;
//         }
//       }
//
//       // Return extracted data if we have at least name or national ID
//       if (data['fullName'] != null || data['nationalId'] != null) {
//         return ExtractedDocumentData(
//           fullName: data['fullName'],
//           nationalId: data['nationalId'],
//           birthDate:
//               data['birthDate'] != null
//                   ? DateTime.tryParse(data['birthDate']!)
//                   : null,
//           address: data['address'],
//         );
//       }
//
//       return null;
//     } catch (e) {
//       print('$_logTag خطأ في تحليل النص للهوية: $e');
//       return null;
//     }
//   }
//
//   /// Parse passport text
//   static ExtractedDocumentData? _parsePassportText(String text) {
//     try {
//       final Map<String, String?> data = {};
//
//       // Extract passport number (various formats)
//       final passportPatterns = [
//         r'\b[A-Z]\d{7,8}\b', // Format: A1234567
//         r'\b\d{8,9}\b', // Format: 12345678
//         r'\b[A-Z]{2}\d{6,7}\b', // Format: AB123456
//       ];
//
//       for (final pattern in passportPatterns) {
//         final match = RegExp(pattern).firstMatch(text.toUpperCase());
//         if (match != null) {
//           data['passportNumber'] = match.group(0);
//           print(
//             '$_logTag تم استخراج رقم جواز السفر: ${data['passportNumber']}',
//           );
//           break;
//         }
//       }
//
//       // Extract English name
//       final englishNameRegex = RegExp(r'\b[A-Z][a-zA-Z\s]{10,}\b');
//       final nameMatch = englishNameRegex.firstMatch(text);
//       if (nameMatch != null) {
//         data['fullName'] = nameMatch.group(0)?.trim();
//         print('$_logTag تم استخراج الاسم: ${data['fullName']}');
//       }
//
//       // Extract dates
//       final dateRegex = RegExp(r'\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{4}\b');
//       final dateMatches = dateRegex.allMatches(text);
//
//       if (dateMatches.isNotEmpty) {
//         final dateStr = dateMatches.first.group(0)!;
//         final formattedDate = _formatDate(dateStr);
//         if (formattedDate != null) {
//           data['birthDate'] = formattedDate;
//           print('$_logTag تم استخراج تاريخ الميلاد: $formattedDate');
//         }
//       }
//
//       // Extract nationality
//       final nationalityKeywords = ['EGYPT', 'EGYPTIAN', 'مصر', 'مصري'];
//       for (final keyword in nationalityKeywords) {
//         if (text.toUpperCase().contains(keyword)) {
//           data['nationality'] = 'مصري';
//           break;
//         }
//       }
//
//       if (data['passportNumber'] != null || data['fullName'] != null) {
//         return ExtractedDocumentData(
//           fullName: data['fullName'],
//           passportNumber: data['passportNumber'],
//           birthDate:
//               data['birthDate'] != null
//                   ? DateTime.tryParse(data['birthDate']!)
//                   : null,
//           nationality: data['nationality'],
//         );
//       }
//
//       return null;
//     } catch (e) {
//       print('$_logTag خطأ في تحليل النص للجواز: $e');
//       return null;
//     }
//   }
//
//   /// Clean Arabic text by removing unwanted characters
//   static String _cleanArabicText(String text) {
//     return text
//         .replaceAll(
//           RegExp(r'[^\u0600-\u06FF\s]'),
//           '',
//         ) // Keep only Arabic and spaces
//         .replaceAll(
//           RegExp(r'\s+'),
//           ' ',
//         ) // Replace multiple spaces with single space
//         .trim();
//   }
//
//   /// Extract birth date from Egyptian national ID
//   static String? _extractDateFromNationalId(String nationalId) {
//     try {
//       if (nationalId.length != 14) return null;
//
//       final yearPart = nationalId.substring(1, 3);
//       final monthPart = nationalId.substring(3, 5);
//       final dayPart = nationalId.substring(5, 7);
//
//       // Determine century based on first digit
//       final centuryDigit = int.parse(nationalId.substring(0, 1));
//       String fullYear;
//
//       if (centuryDigit == 2) {
//         fullYear = '19$yearPart';
//       } else if (centuryDigit == 3) {
//         fullYear = '20$yearPart';
//       } else {
//         return null;
//       }
//
//       return '$fullYear-$monthPart-$dayPart';
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// Format date string to ISO format
//   static String? _formatDate(String dateStr) {
//     try {
//       final parts = dateStr.split(RegExp(r'[\/\-\.]'));
//       if (parts.length != 3) return null;
//
//       final day = parts[0].padLeft(2, '0');
//       final month = parts[1].padLeft(2, '0');
//       final year = parts[2];
//
//       return '$year-$month-$day';
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// Get image file size in KB
//   static Future<double> _getImageSize(File imageFile) async {
//     try {
//       final bytes = await imageFile.length();
//       return bytes / 1024;
//     } catch (e) {
//       return 0;
//     }
//   }
//
//   /// Clean up temporary files
//   static Future<void> cleanup() async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final tempFiles =
//           tempDir
//               .listSync()
//               .whereType<File>()
//               .where((file) => file.path.contains('document_scan'))
//               .toList();
//
//       for (final file in tempFiles) {
//         try {
//           await file.delete();
//         } catch (e) {
//           print('$_logTag خطأ في حذف الملف المؤقت: $e');
//         }
//       }
//
//       print('$_logTag تم تنظيف ${tempFiles.length} ملف مؤقت');
//     } catch (e) {
//       print('$_logTag خطأ في تنظيف الملفات المؤقتة: $e');
//     }
//   }
// }
//
// /// Document scan result containing the processed image and extracted data
// class DocumentScanResult {
//   final File imageFile;
//   final ExtractedDocumentData? extractedData;
//   final double originalImageSize;
//   final double compressedImageSize;
//
//   DocumentScanResult({
//     required this.imageFile,
//     this.extractedData,
//     required this.originalImageSize,
//     required this.compressedImageSize,
//   });
//
//   double get compressionRatio {
//     if (originalImageSize == 0) return 0;
//     return ((compressedImageSize - originalImageSize) / originalImageSize) *
//         100;
//   }
// }
