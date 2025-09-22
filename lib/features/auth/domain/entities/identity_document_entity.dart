import 'package:equatable/equatable.dart';

enum DocumentType { nationalId, passport }

extension DocumentTypeExtension on DocumentType {
  String get arabicName {
    switch (this) {
      case DocumentType.nationalId:
        return 'البطاقة الشخصية';
      case DocumentType.passport:
        return 'جواز السفر';
    }
  }

  String get value {
    switch (this) {
      case DocumentType.nationalId:
        return 'nationalId';
      case DocumentType.passport:
        return 'passport';
    }
  }
}

class IdentityDocumentEntity extends Equatable {
  final String? id;
  final String userId;
  final DocumentType docType;
  final String? frontImageUrl;
  final String? backImageUrl;
  final DateTime? createdAt;

  const IdentityDocumentEntity({
    this.id,
    required this.userId,
    required this.docType,
    this.frontImageUrl,
    this.backImageUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    docType,
    frontImageUrl,
    backImageUrl,
    createdAt,
  ];

  IdentityDocumentEntity copyWith({
    String? id,
    String? userId,
    DocumentType? docType,
    String? frontImageUrl,
    String? backImageUrl,
    DateTime? createdAt,
  }) {
    return IdentityDocumentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      docType: docType ?? this.docType,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
