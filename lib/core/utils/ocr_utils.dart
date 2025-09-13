// import 'dart:io';
// import 'package:tesseract_ocr/tesseract_ocr.dart';
// import 'egyptian_id_parser.dart';
//
// /// Utility class for OCR text extraction and processing
// class OCRUtils {
//   /// Extract text from image using Tesseract OCR
//   static Future<String?> extractTextFromImage(File imageFile) async {
//     try {
//       final text = await TesseractOcr.extractText(imageFile.path);
//       print('🔍 OCR extracted text: $text');
//       return text.isNotEmpty ? text : null;
//     } catch (e) {
//       print('❌ Error extracting text: $e');
//       return null;
//     }
//   }
//
//   /// Extract structured data from Egyptian national ID
//   static Map<String, String?> extractNationalIdData(String text) {
//     final result = <String, String?>{
//       'nationalId': null,
//       'fullName': null,
//       'address': null,
//       'dateOfBirth': null,
//     };
//
//     // Extract 14-digit national ID
//     final nationalIdMatch = RegExp(r'\b\d{14}\b').firstMatch(text);
//     if (nationalIdMatch != null) {
//       final nationalId = nationalIdMatch.group(0)!;
//       result['nationalId'] = nationalId;
//
//       // Extract date of birth from national ID
//       final dob = EgyptianIdParser.parseEgyptianNationalIdToDOB(nationalId);
//       if (dob != null) {
//         result['dateOfBirth'] =
//             '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
//       }
//     }
//
//     // Extract Arabic name (multiple words with Arabic characters)
//     final arabicNameMatch = RegExp(r'[\u0600-\u06FF\s]{3,}').allMatches(text);
//     if (arabicNameMatch.isNotEmpty) {
//       // Get the longest Arabic text as it's likely the full name
//       String? longestName;
//       int maxLength = 0;
//
//       for (final match in arabicNameMatch) {
//         final name = match.group(0)?.trim();
//         if (name != null &&
//             name.length > maxLength &&
//             name.split(' ').length >= 2) {
//           maxLength = name.length;
//           longestName = name;
//         }
//       }
//
//       if (longestName != null && longestName.length > 10) {
//         result['fullName'] = _cleanArabicText(longestName);
//       }
//     }
//
//     // Extract address (lines containing address keywords)
//     final addressKeywords = ['محافظة', 'مركز', 'قسم', 'شارع', 'حي', 'مدينة'];
//     final lines = text.split('\n');
//
//     for (final line in lines) {
//       final cleanLine = line.trim();
//       if (cleanLine.length > 10 &&
//           addressKeywords.any((keyword) => cleanLine.contains(keyword))) {
//         result['address'] = _cleanArabicText(cleanLine);
//         break;
//       }
//     }
//
//     return result;
//   }
//
//   /// Extract data from passport
//   static Map<String, String?> extractPassportData(String text) {
//     final result = <String, String?>{
//       'passportNumber': null,
//       'fullName': null,
//       'dateOfBirth': null,
//       'nationality': null,
//     };
//
//     // Extract passport number (various formats)
//     final passportPatterns = [
//       r'\b[A-Z]\d{7,8}\b', // Format: A1234567
//       r'\b\d{8,9}\b', // Format: 12345678
//       r'\b[A-Z]{2}\d{6,7}\b', // Format: AB123456
//     ];
//
//     for (final pattern in passportPatterns) {
//       final match = RegExp(pattern).firstMatch(text);
//       if (match != null) {
//         result['passportNumber'] = match.group(0);
//         break;
//       }
//     }
//
//     // Extract dates (potential date of birth)
//     final datePattern = RegExp(r'\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{4}\b');
//     final dateMatches = datePattern.allMatches(text);
//
//     if (dateMatches.isNotEmpty) {
//       // Take the first date as DOB (passports usually have DOB before expiry)
//       final dateStr = dateMatches.first.group(0)!;
//       result['dateOfBirth'] = _formatDate(dateStr);
//     }
//
//     // Extract name from English text
//     final englishNameMatch = RegExp(
//       r'\b[A-Z][a-zA-Z\s]{10,}\b',
//     ).firstMatch(text);
//     if (englishNameMatch != null) {
//       result['fullName'] = englishNameMatch.group(0)?.trim();
//     }
//
//     return result;
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
//   /// Format date string to YYYY-MM-DD
//   static String? _formatDate(String dateStr) {
//     try {
//       final parts = dateStr.split(RegExp(r'[\/\-\.]'));
//       if (parts.length != 3) return null;
//
//       int day = int.parse(parts[0]);
//       int month = int.parse(parts[1]);
//       int year = int.parse(parts[2]);
//
//       // Handle 2-digit years
//       if (year < 100) {
//         year += (year > 50) ? 1900 : 2000;
//       }
//
//       return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// Dispose resources
//   static void dispose() {
//     // No cleanup needed for Tesseract OCR
//   }
// }
