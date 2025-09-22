import 'package:equatable/equatable.dart';

class IdentityDocumentEntity extends Equatable {
  final String id;
  final String userId;
  final DocumentType docType;
  final String? frontImageUrl;
  final String? backImageUrl;
  final DateTime uploadedAt;
  final DateTime createdAt;

  const IdentityDocumentEntity({
    required this.id,
    required this.userId,
    required this.docType,
    this.frontImageUrl,
    this.backImageUrl,
    required this.uploadedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    docType,
    frontImageUrl,
    backImageUrl,
    uploadedAt,
    createdAt,
  ];
}

enum DocumentType { nationalId, passport }

extension DocumentTypeExtension on DocumentType {
  String get value {
    switch (this) {
      case DocumentType.nationalId:
        return 'nationalId';
      case DocumentType.passport:
        return 'passport';
    }
  }

  String get arabicName {
    switch (this) {
      case DocumentType.nationalId:
        return 'البطاقة الشخصية';
      case DocumentType.passport:
        return 'جواز السفر';
    }
  }

  static DocumentType fromString(String value) {
    switch (value) {
      case 'nationalId':
        return DocumentType.nationalId;
      case 'passport':
        return DocumentType.passport;
      default:
        return DocumentType.nationalId;
    }
  }
}
