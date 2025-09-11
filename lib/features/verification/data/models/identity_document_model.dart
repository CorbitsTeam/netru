import '../../domain/entities/identity_document.dart';

class IdentityDocumentModel extends IdentityDocument {
  const IdentityDocumentModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.documentNumber,
    required super.fullName,
    required super.dateOfBirth,
    super.nationality,
    super.expiryDate,
    super.issueDate,
    super.placeOfBirth,
    required super.imageUrl,
    super.extractedDataJson,
    required super.status,
    required super.createdAt,
    super.verifiedAt,
    super.rejectionReason,
  });

  factory IdentityDocumentModel.fromJson(Map<String, dynamic> json) {
    return IdentityDocumentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: _parseDocumentType(json['document_type']),
      documentNumber: json['document_number'] ?? '',
      fullName: json['full_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      nationality: json['nationality'],
      expiryDate: json['expiry_date'],
      issueDate: json['issue_date'],
      placeOfBirth: json['place_of_birth'],
      imageUrl: json['image_url'] ?? '',
      extractedDataJson: json['extracted_data_json'],
      status: _parseDocumentStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'document_type': _documentTypeToString(type),
      'document_number': documentNumber,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'nationality': nationality,
      'expiry_date': expiryDate,
      'issue_date': issueDate,
      'place_of_birth': placeOfBirth,
      'image_url': imageUrl,
      'extracted_data_json': extractedDataJson,
      'status': _documentStatusToString(status),
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  factory IdentityDocumentModel.fromEntity(IdentityDocument entity) {
    return IdentityDocumentModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      documentNumber: entity.documentNumber,
      fullName: entity.fullName,
      dateOfBirth: entity.dateOfBirth,
      nationality: entity.nationality,
      expiryDate: entity.expiryDate,
      issueDate: entity.issueDate,
      placeOfBirth: entity.placeOfBirth,
      imageUrl: entity.imageUrl,
      extractedDataJson: entity.extractedDataJson,
      status: entity.status,
      createdAt: entity.createdAt,
      verifiedAt: entity.verifiedAt,
      rejectionReason: entity.rejectionReason,
    );
  }

  static DocumentType _parseDocumentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'national_id':
      case 'nationalid':
        return DocumentType.nationalId;
      case 'passport':
        return DocumentType.passport;
      default:
        return DocumentType.nationalId;
    }
  }

  static String _documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return 'national_id';
      case DocumentType.passport:
        return 'passport';
    }
  }

  static DocumentStatus _parseDocumentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return DocumentStatus.pending;
      case 'verified':
        return DocumentStatus.verified;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  static String _documentStatusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'pending';
      case DocumentStatus.verified:
        return 'verified';
      case DocumentStatus.rejected:
        return 'rejected';
    }
  }

  @override
  IdentityDocumentModel copyWith({
    String? id,
    String? userId,
    DocumentType? type,
    String? documentNumber,
    String? fullName,
    String? dateOfBirth,
    String? nationality,
    String? expiryDate,
    String? issueDate,
    String? placeOfBirth,
    String? imageUrl,
    String? extractedDataJson,
    DocumentStatus? status,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? rejectionReason,
  }) {
    return IdentityDocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      expiryDate: expiryDate ?? this.expiryDate,
      issueDate: issueDate ?? this.issueDate,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      imageUrl: imageUrl ?? this.imageUrl,
      extractedDataJson: extractedDataJson ?? this.extractedDataJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
