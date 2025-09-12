import 'package:equatable/equatable.dart';

/// نتيجة استخراج النصوص من الصور (OCR)
class OcrResult extends Equatable {
  final bool success;
  final String rawText;
  final Map<String, dynamic> extractedData;
  final String? errorMessage;
  final double confidence;

  const OcrResult({
    required this.success,
    required this.rawText,
    required this.extractedData,
    this.errorMessage,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [
    success,
    rawText,
    extractedData,
    errorMessage,
    confidence,
  ];

  factory OcrResult.success({
    required String rawText,
    required Map<String, dynamic> extractedData,
    double confidence = 1.0,
  }) => OcrResult(
    success: true,
    rawText: rawText,
    extractedData: extractedData,
    confidence: confidence,
  );

  factory OcrResult.failure({
    required String errorMessage,
    String rawText = '',
  }) => OcrResult(
    success: false,
    rawText: rawText,
    extractedData: const {},
    errorMessage: errorMessage,
  );

  OcrResult copyWith({
    bool? success,
    String? rawText,
    Map<String, dynamic>? extractedData,
    String? errorMessage,
    double? confidence,
  }) {
    return OcrResult(
      success: success ?? this.success,
      rawText: rawText ?? this.rawText,
      extractedData: extractedData ?? this.extractedData,
      errorMessage: errorMessage ?? this.errorMessage,
      confidence: confidence ?? this.confidence,
    );
  }
}

/// بيانات البطاقة المستخرجة من OCR
class EgyptianIdData extends Equatable {
  final String? name;
  final String? nationalId;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? religion;
  final String? job;
  final String? motherName;

  const EgyptianIdData({
    this.name,
    this.nationalId,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.religion,
    this.job,
    this.motherName,
  });

  @override
  List<Object?> get props => [
    name,
    nationalId,
    address,
    dateOfBirth,
    gender,
    religion,
    job,
    motherName,
  ];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'national_id': nationalId,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'religion': religion,
      'job': job,
      'mother_name': motherName,
    };
  }

  factory EgyptianIdData.fromMap(Map<String, dynamic> map) {
    return EgyptianIdData(
      name: map['name'],
      nationalId: map['national_id'],
      address: map['address'],
      dateOfBirth:
          map['date_of_birth'] != null
              ? DateTime.tryParse(map['date_of_birth'])
              : null,
      gender: map['gender'],
      religion: map['religion'],
      job: map['job'],
      motherName: map['mother_name'],
    );
  }

  EgyptianIdData copyWith({
    String? name,
    String? nationalId,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? religion,
    String? job,
    String? motherName,
  }) {
    return EgyptianIdData(
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      job: job ?? this.job,
      motherName: motherName ?? this.motherName,
    );
  }

  bool get isValid => name != null && nationalId != null;
}

/// بيانات جواز السفر المستخرجة من OCR
class PassportData extends Equatable {
  final String? name;
  final String? passportNumber;
  final String? nationality;
  final DateTime? dateOfBirth;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? placeOfBirth;
  final String? gender;

  const PassportData({
    this.name,
    this.passportNumber,
    this.nationality,
    this.dateOfBirth,
    this.issueDate,
    this.expiryDate,
    this.placeOfBirth,
    this.gender,
  });

  @override
  List<Object?> get props => [
    name,
    passportNumber,
    nationality,
    dateOfBirth,
    issueDate,
    expiryDate,
    placeOfBirth,
    gender,
  ];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'passport_number': passportNumber,
      'nationality': nationality,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'issue_date': issueDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'place_of_birth': placeOfBirth,
      'gender': gender,
    };
  }

  factory PassportData.fromMap(Map<String, dynamic> map) {
    return PassportData(
      name: map['name'],
      passportNumber: map['passport_number'],
      nationality: map['nationality'],
      dateOfBirth:
          map['date_of_birth'] != null
              ? DateTime.tryParse(map['date_of_birth'])
              : null,
      issueDate:
          map['issue_date'] != null
              ? DateTime.tryParse(map['issue_date'])
              : null,
      expiryDate:
          map['expiry_date'] != null
              ? DateTime.tryParse(map['expiry_date'])
              : null,
      placeOfBirth: map['place_of_birth'],
      gender: map['gender'],
    );
  }

  PassportData copyWith({
    String? name,
    String? passportNumber,
    String? nationality,
    DateTime? dateOfBirth,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? placeOfBirth,
    String? gender,
  }) {
    return PassportData(
      name: name ?? this.name,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      gender: gender ?? this.gender,
    );
  }

  bool get isValid => name != null && passportNumber != null;
}
