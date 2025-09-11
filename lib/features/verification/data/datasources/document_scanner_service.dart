import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/extracted_document_data.dart';
import '../../domain/entities/identity_document.dart';

abstract class DocumentScannerService {
  Future<ExtractedDocumentData> scanDocument({
    required File imageFile,
    required DocumentType documentType,
  });
}

class DocumentScannerServiceImpl implements DocumentScannerService {
  final TextRecognizer _textRecognizer;
  final Logger _logger;

  DocumentScannerServiceImpl({
    required TextRecognizer textRecognizer,
    required Logger logger,
  }) : _textRecognizer = textRecognizer,
       _logger = logger;

  @override
  Future<ExtractedDocumentData> scanDocument({
    required File imageFile,
    required DocumentType documentType,
  }) async {
    try {
      _logger.i('Starting document scan for ${documentType.name}');

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedData =
          documentType == DocumentType.nationalId
              ? _extractNationalIdData(recognizedText)
              : _extractPassportData(recognizedText);

      _logger.i(
        'Document scan completed with confidence: ${extractedData.confidence}',
      );
      return extractedData;
    } catch (e) {
      _logger.e('Error scanning document: $e');
      throw Exception('Failed to scan document: $e');
    }
  }

  ExtractedDocumentData _extractNationalIdData(RecognizedText recognizedText) {
    final text = recognizedText.text;
    final lines = text.split('\n').map((line) => line.trim()).toList();

    _logger.d('Recognized text lines: $lines');

    String fullName = '';
    String documentNumber = '';
    String dateOfBirth = '';
    String nationality = 'مصري'; // Default for Egyptian ID
    String? gender;
    String? address;
    double confidence = 0.0;

    // Egyptian National ID patterns
    final namePattern = RegExp(r'[أ-ي\s]+');
    final idNumberPattern = RegExp(r'\d{14}');
    final datePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{4}');
    final genderPattern = RegExp(
      r'(ذكر|انثى|male|female)',
      caseSensitive: false,
    );

    int recognizedFields = 0;
    const totalFields = 3; // name, id, date

    for (final line in lines) {
      // Extract ID number (14 digits for Egyptian ID)
      if (documentNumber.isEmpty) {
        final idMatch = idNumberPattern.firstMatch(line);
        if (idMatch != null) {
          documentNumber = idMatch.group(0)!;
          recognizedFields++;
          _logger.d('Found ID number: $documentNumber');
        }
      }

      // Extract date of birth
      if (dateOfBirth.isEmpty) {
        final dateMatch = datePattern.firstMatch(line);
        if (dateMatch != null) {
          dateOfBirth = dateMatch.group(0)!;
          recognizedFields++;
          _logger.d('Found date of birth: $dateOfBirth');
        }
      }

      // Extract gender
      if (gender == null) {
        final genderMatch = genderPattern.firstMatch(line);
        if (genderMatch != null) {
          gender = genderMatch.group(0)!;
          _logger.d('Found gender: $gender');
        }
      }

      // Extract name (Arabic text, usually longest line with Arabic characters)
      if (fullName.isEmpty && namePattern.hasMatch(line) && line.length > 10) {
        // Remove any digits or special characters
        final cleanName = line.replaceAll(RegExp(r'[0-9\-/]'), '').trim();
        if (cleanName.length > fullName.length && cleanName.length > 5) {
          fullName = cleanName;
          recognizedFields++;
          _logger.d('Found name: $fullName');
        }
      }
    }

    // Calculate confidence based on recognized fields
    confidence = recognizedFields / totalFields;

    return ExtractedDocumentData(
      fullName: fullName,
      documentNumber: documentNumber,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      gender: gender,
      address: address,
      confidence: confidence,
      rawData: {
        'recognizedText': text,
        'lines': lines,
        'documentType': 'national_id',
      },
    );
  }

  ExtractedDocumentData _extractPassportData(RecognizedText recognizedText) {
    final text = recognizedText.text;
    final lines = text.split('\n').map((line) => line.trim()).toList();

    _logger.d('Recognized passport text lines: $lines');

    String fullName = '';
    String documentNumber = '';
    String dateOfBirth = '';
    String? nationality;
    String? expiryDate;
    String? issueDate;
    String? placeOfBirth;
    String? gender;
    double confidence = 0.0;

    // Passport patterns
    final passportNumberPattern = RegExp(r'[A-Z]\d{7,8}');
    final datePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{4}');
    final namePattern = RegExp(r'[A-Z\s]{10,}');
    final nationalityPattern = RegExp(r'(EGY|USA|GBR|FRA|DEU|[A-Z]{3})');

    int recognizedFields = 0;
    const totalFields = 3; // name, passport number, date

    for (final line in lines) {
      // Extract passport number
      if (documentNumber.isEmpty) {
        final passportMatch = passportNumberPattern.firstMatch(line);
        if (passportMatch != null) {
          documentNumber = passportMatch.group(0)!;
          recognizedFields++;
          _logger.d('Found passport number: $documentNumber');
        }
      }

      // Extract dates
      final dateMatches = datePattern.allMatches(line);
      for (final match in dateMatches) {
        final date = match.group(0)!;
        if (dateOfBirth.isEmpty) {
          dateOfBirth = date;
          recognizedFields++;
          _logger.d('Found date of birth: $dateOfBirth');
        } else if (expiryDate == null) {
          expiryDate = date;
          _logger.d('Found expiry date: $expiryDate');
        }
      }

      // Extract nationality
      if (nationality == null) {
        final nationalityMatch = nationalityPattern.firstMatch(line);
        if (nationalityMatch != null) {
          nationality = nationalityMatch.group(0)!;
          _logger.d('Found nationality: $nationality');
        }
      }

      // Extract name (uppercase text, usually longest line)
      if (fullName.isEmpty && namePattern.hasMatch(line)) {
        final cleanName = line.replaceAll(RegExp(r'[0-9\-/]'), '').trim();
        if (cleanName.length > fullName.length && cleanName.length > 5) {
          fullName = cleanName;
          recognizedFields++;
          _logger.d('Found name: $fullName');
        }
      }
    }

    // Calculate confidence
    confidence = recognizedFields / totalFields;

    return ExtractedDocumentData(
      fullName: fullName,
      documentNumber: documentNumber,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      expiryDate: expiryDate,
      issueDate: issueDate,
      placeOfBirth: placeOfBirth,
      gender: gender,
      confidence: confidence,
      rawData: {
        'recognizedText': text,
        'lines': lines,
        'documentType': 'passport',
      },
    );
  }
}
