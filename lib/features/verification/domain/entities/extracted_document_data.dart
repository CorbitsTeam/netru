import 'package:equatable/equatable.dart';

class ExtractedDocumentData extends Equatable {
  final String fullName;
  final String documentNumber;
  final String dateOfBirth;
  final String? nationality;
  final String? expiryDate;
  final String? issueDate;
  final String? placeOfBirth;
  final String? gender;
  final String? address;
  final double confidence;
  final Map<String, dynamic> rawData;

  const ExtractedDocumentData({
    required this.fullName,
    required this.documentNumber,
    required this.dateOfBirth,
    this.nationality,
    this.expiryDate,
    this.issueDate,
    this.placeOfBirth,
    this.gender,
    this.address,
    required this.confidence,
    required this.rawData,
  });

  @override
  List<Object?> get props => [
    fullName,
    documentNumber,
    dateOfBirth,
    nationality,
    expiryDate,
    issueDate,
    placeOfBirth,
    gender,
    address,
    confidence,
    rawData,
  ];

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'documentNumber': documentNumber,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'expiryDate': expiryDate,
      'issueDate': issueDate,
      'placeOfBirth': placeOfBirth,
      'gender': gender,
      'address': address,
      'confidence': confidence,
      'rawData': rawData,
    };
  }

  factory ExtractedDocumentData.fromJson(Map<String, dynamic> json) {
    return ExtractedDocumentData(
      fullName: json['fullName'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      nationality: json['nationality'],
      expiryDate: json['expiryDate'],
      issueDate: json['issueDate'],
      placeOfBirth: json['placeOfBirth'],
      gender: json['gender'],
      address: json['address'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      rawData: json['rawData'] ?? {},
    );
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
}
