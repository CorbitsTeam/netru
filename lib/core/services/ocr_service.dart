// import 'dart:io';
// import 'package:tesseract_ocr/tesseract_ocr.dart';
// import '../../features/auth/domain/entities/extracted_document_data.dart';
//
// class OCRService {
//   /// استخراج النص من البطاقة الشخصية المصرية
//   static Future<ExtractedDocumentData?> extractFromEgyptianID(
//     File imageFile,
//   ) async {
//     try {
//       // استخراج النص باستخدام Tesseract مع دعم العربية والإنجليزية
//       String text = await TesseractOcr.extractText(imageFile.path);
//
//       print('🔍 النص المستخرج من البطاقة: $text');
//
//       if (text.isEmpty) return null;
//
//       List<String> lines =
//           text
//               .split('\n')
//               .map((line) => line.trim())
//               .where((line) => line.isNotEmpty)
//               .toList();
//
//       print('📄 الأسطر المستخرجة: $lines');
//
//       return _parseEgyptianIDText(lines);
//     } catch (e) {
//       print('❌ خطأ في استخراج النص من البطاقة: $e');
//       return null;
//     }
//   }
//
//   /// استخراج النص من جواز السفر
//   static Future<ExtractedDocumentData?> extractFromPassport(
//     File imageFile,
//   ) async {
//     try {
//       // استخراج النص باستخدام Tesseract مع دعم العربية والإنجليزية
//       String text = await TesseractOcr.extractText(imageFile.path);
//
//       print('🔍 النص المستخرج من جواز السفر: $text');
//
//       if (text.isEmpty) return null;
//
//       List<String> lines =
//           text
//               .split('\n')
//               .map((line) => line.trim())
//               .where((line) => line.isNotEmpty)
//               .toList();
//
//       print('📄 الأسطر المستخرجة: $lines');
//
//       return _parsePassportText(lines);
//     } catch (e) {
//       print('❌ خطأ في استخراج النص من جواز السفر: $e');
//       return null;
//     }
//   }
//
//   /// تحليل نص البطاقة الشخصية المصرية
//   static ExtractedDocumentData? _parseEgyptianIDText(List<String> lines) {
//     try {
//       String? fullName;
//       String? nationalId;
//       DateTime? birthDate;
//       String? address;
//
//       for (int i = 0; i < lines.length; i++) {
//         String line = lines[i];
//         print('Processing line: $line');
//
//         // البحث عن الاسم - عادة يكون أول اسم عربي طويل
//         if (fullName == null && _isArabicName(line) && line.length > 8) {
//           fullName = line;
//           print('Found name: $fullName');
//         }
//
//         // البحث عن الرقم القومي - 14 رقم
//         if (nationalId == null) {
//           String? id = _extractNationalId(line);
//           if (id != null) {
//             nationalId = id;
//             print('Found national ID: $nationalId');
//           }
//         }
//
//         // البحث عن تاريخ الميلاد
//         if (birthDate == null) {
//           DateTime? date = _extractBirthDate(line);
//           if (date != null) {
//             birthDate = date;
//             print('Found birth date: $birthDate');
//           }
//         }
//
//         // البحث عن العنوان - عادة يكون أطول النصوص العربية
//         if (address == null && _isArabicAddress(line) && line.length > 15) {
//           address = line;
//           print('Found address: $address');
//         }
//       }
//
//       // التحقق من وجود بيانات كافية
//       if (fullName != null || nationalId != null) {
//         final result = ExtractedDocumentData(
//           fullName: fullName,
//           nationalId: nationalId,
//           birthDate: birthDate,
//           address: address,
//         );
//         print('Extraction result: ${result.toString()}');
//         return result;
//       }
//
//       print('No sufficient data found');
//       return null;
//     } catch (e) {
//       print('خطأ في تحليل نص البطاقة الشخصية: $e');
//       return null;
//     }
//   }
//
//   /// تحليل نص جواز السفر
//   static ExtractedDocumentData? _parsePassportText(List<String> lines) {
//     try {
//       String? fullName;
//       String? passportNumber;
//       String? nationality;
//       DateTime? birthDate;
//       DateTime? issueDate;
//       DateTime? expiryDate;
//
//       for (String line in lines) {
//         // البحث عن رقم جواز السفر
//         if (passportNumber == null) {
//           String? passport = _extractPassportNumber(line);
//           if (passport != null) {
//             passportNumber = passport;
//           }
//         }
//
//         // البحث عن الاسم
//         if (fullName == null && _isArabicName(line) && line.length > 8) {
//           fullName = line;
//         }
//
//         // البحث عن الجنسية
//         if (nationality == null && _isNationality(line)) {
//           nationality = line;
//         }
//
//         // البحث عن التواريخ
//         List<DateTime> dates = _extractDatesFromLine(line);
//         for (DateTime date in dates) {
//           if (birthDate == null && _isBirthDate(date)) {
//             birthDate = date;
//           } else if (issueDate == null && _isIssueDate(date)) {
//             issueDate = date;
//           } else if (expiryDate == null && _isExpiryDate(date)) {
//             expiryDate = date;
//           }
//         }
//       }
//
//       if (fullName != null && passportNumber != null) {
//         return ExtractedDocumentData(
//           fullName: fullName,
//           passportNumber: passportNumber,
//           nationality: nationality,
//           birthDate: birthDate,
//           passportIssueDate: issueDate,
//           passportExpiryDate: expiryDate,
//         );
//       }
//
//       return null;
//     } catch (e) {
//       print('خطأ في تحليل نص جواز السفر: $e');
//       return null;
//     }
//   }
//
//   // دوال مساعدة لتحليل النصوص
//
//   static bool _isArabicName(String text) {
//     // التحقق من وجود أحرف عربية وأن النص يبدو كاسم
//     if (!RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return false;
//     if (RegExp(r'[0-9]').hasMatch(text)) return false;
//
//     // يجب أن يحتوي على على الأقل كلمتين
//     List<String> words = text.trim().split(RegExp(r'\s+'));
//     if (words.length < 2) return false;
//
//     // تجنب الكلمات الشائعة التي ليست أسماء
//     List<String> excludeWords = [
//       'جمهورية',
//       'مصر',
//       'العربية',
//       'وزارة',
//       'الداخلية',
//       'بطاقة',
//       'رقم',
//       'قومي',
//       'محافظة',
//       'مدينة',
//       'قرية',
//       'شارع',
//       'الاسم',
//       'التاريخ',
//       'المحل',
//     ];
//
//     for (String word in words) {
//       if (excludeWords.contains(word)) return false;
//     }
//
//     return true;
//   }
//
//   static bool _isArabicAddress(String text) {
//     // التحقق من وجود أحرف عربية وكلمات تدل على العنوان
//     if (!RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return false;
//
//     List<String> addressIndicators = [
//       'شارع',
//       'محافظة',
//       'مدينة',
//       'حي',
//       'منطقة',
//       'قرية',
//       'كفر',
//       'ميت',
//       'أبو',
//       'بني',
//       'المحلة',
//       'طنطا',
//       'المنصورة',
//       'أسيوط',
//       'سوهاج',
//       'قنا',
//       'أسوان',
//       'الفيوم',
//       'بنها',
//       'شبين',
//       'دمنهور',
//       'كفر الشيخ',
//     ];
//
//     return addressIndicators.any((indicator) => text.contains(indicator));
//   }
//
//   static String? _extractNationalId(String text) {
//     // البحث عن 14 رقم متتالي
//     RegExp nationalIdRegex = RegExp(r'\b\d{14}\b');
//     Match? match = nationalIdRegex.firstMatch(text);
//     String? id = match?.group(0);
//
//     if (id != null) {
//       // التحقق من صحة الرقم القومي (يجب أن يبدأ بسنة معقولة)
//       String year = id.substring(1, 3);
//       int yearInt = int.tryParse(year) ?? 0;
//       // إذا كان العامان الأولان أقل من 30، فهو من 2000s، وإلا من 1900s
//       int fullYear = yearInt < 30 ? 2000 + yearInt : 1900 + yearInt;
//       int currentYear = DateTime.now().year;
//
//       if (fullYear >= 1920 && fullYear <= currentYear) {
//         print('Valid national ID found: $id');
//         return id;
//       }
//     }
//
//     return null;
//   }
//
//   static String? _extractPassportNumber(String text) {
//     // أرقام جوازات السفر عادة تكون حروف وأرقام
//     RegExp passportRegex = RegExp(r'\b[A-Z0-9]{6,12}\b');
//     Match? match = passportRegex.firstMatch(text.toUpperCase());
//     return match?.group(0);
//   }
//
//   static DateTime? _extractBirthDate(String text) {
//     // البحث عن تواريخ بصيغ مختلفة
//     List<RegExp> datePatterns = [
//       RegExp(r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{4})\b'),
//       RegExp(r'\b(\d{4})[/\-\.](\d{1,2})[/\-\.](\d{1,2})\b'),
//       RegExp(r'\b(\d{1,2})\s+(\d{1,2})\s+(\d{4})\b'),
//       RegExp(r'\b(\d{1,2})(\d{2})(\d{4})\b'), // DDMMYYYY format
//     ];
//
//     for (RegExp pattern in datePatterns) {
//       Iterable<Match> matches = pattern.allMatches(text);
//       for (Match match in matches) {
//         try {
//           int day, month, year;
//           if (pattern == datePatterns[1]) {
//             // YYYY/MM/DD format
//             year = int.parse(match.group(1)!);
//             month = int.parse(match.group(2)!);
//             day = int.parse(match.group(3)!);
//           } else if (pattern == datePatterns[3]) {
//             // DDMMYYYY format
//             day = int.parse(match.group(1)!);
//             month = int.parse(match.group(2)!);
//             year = int.parse(match.group(3)!);
//           } else {
//             // DD/MM/YYYY format
//             day = int.parse(match.group(1)!);
//             month = int.parse(match.group(2)!);
//             year = int.parse(match.group(3)!);
//           }
//
//           if (day > 0 && day <= 31 && month > 0 && month <= 12) {
//             DateTime date = DateTime(year, month, day);
//             if (_isBirthDate(date)) {
//               print('Valid birth date found: $date');
//               return date;
//             }
//           }
//         } catch (e) {
//           continue;
//         }
//       }
//     }
//     return null;
//   }
//
//   static List<DateTime> _extractDatesFromLine(String text) {
//     List<DateTime> dates = [];
//     List<RegExp> datePatterns = [
//       RegExp(r'\b(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})\b'),
//       RegExp(r'\b(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})\b'),
//     ];
//
//     for (RegExp pattern in datePatterns) {
//       Iterable<Match> matches = pattern.allMatches(text);
//       for (Match match in matches) {
//         try {
//           int day, month, year;
//           if (pattern == datePatterns[1]) {
//             year = int.parse(match.group(1)!);
//             month = int.parse(match.group(2)!);
//             day = int.parse(match.group(3)!);
//           } else {
//             day = int.parse(match.group(1)!);
//             month = int.parse(match.group(2)!);
//             year = int.parse(match.group(3)!);
//           }
//
//           dates.add(DateTime(year, month, day));
//         } catch (e) {
//           continue;
//         }
//       }
//     }
//     return dates;
//   }
//
//   static bool _isNationality(String text) {
//     List<String> nationalities = [
//       'مصري',
//       'مصرية',
//       'سعودي',
//       'سعودية',
//       'إماراتي',
//       'إماراتية',
//       'كويتي',
//       'كويتية',
//       'قطري',
//       'قطرية',
//       'بحريني',
//       'بحرينية',
//       'عماني',
//       'عمانية',
//       'أردني',
//       'أردنية',
//       'لبناني',
//       'لبنانية',
//       'سوري',
//       'سورية',
//       'عراقي',
//       'عراقية',
//       'يمني',
//       'يمنية',
//       'فلسطيني',
//       'فلسطينية',
//       'مغربي',
//       'مغربية',
//       'جزائري',
//       'جزائرية',
//       'تونسي',
//       'تونسية',
//       'ليبي',
//       'ليبية',
//       'سوداني',
//       'سودانية',
//     ];
//
//     return nationalities.any((nationality) => text.contains(nationality));
//   }
//
//   static bool _isBirthDate(DateTime date) {
//     DateTime now = DateTime.now();
//     int age = now.year - date.year;
//     return age >= 10 && age <= 100; // عمر منطقي
//   }
//
//   static bool _isIssueDate(DateTime date) {
//     DateTime now = DateTime.now();
//     return date.isBefore(now) && date.isAfter(DateTime(1950));
//   }
//
//   static bool _isExpiryDate(DateTime date) {
//     DateTime now = DateTime.now();
//     return date.isAfter(now) && date.isBefore(DateTime(2050));
//   }
//
//   /// تنظيف الموارد
//   static void dispose() {
//     // No cleanup needed for Tesseract
//   }
// }
