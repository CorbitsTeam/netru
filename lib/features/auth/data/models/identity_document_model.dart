import '../../domain/entities/identity_document_entity.dart';

class IdentityDocumentModel extends IdentityDocumentEntity {
  const IdentityDocumentModel({
    super.id,
    required super.userId,
    required super.docType,
    super.frontImageUrl,
    super.backImageUrl,
    super.createdAt,
  });

  factory IdentityDocumentModel.fromJson(Map<String, dynamic> json) {
    return IdentityDocumentModel(
      id: json['id'],
      userId: json['user_id'],
      docType: _parseDocumentType(json['doc_type']),
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'doc_type': docType.name,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{'user_id': userId, 'doc_type': docType.name};

    if (frontImageUrl != null) json['front_image_url'] = frontImageUrl;
    if (backImageUrl != null) json['back_image_url'] = backImageUrl;

    return json;
  }

  static DocumentType _parseDocumentType(String? type) {
    switch (type) {
      case 'nationalId':
        return DocumentType.nationalId;
      case 'passport':
        return DocumentType.passport;
      default:
        return DocumentType.nationalId;
    }
  }

  factory IdentityDocumentModel.fromEntity(IdentityDocumentEntity entity) {
    return IdentityDocumentModel(
      id: entity.id,
      userId: entity.userId,
      docType: entity.docType,
      frontImageUrl: entity.frontImageUrl,
      backImageUrl: entity.backImageUrl,
      createdAt: entity.createdAt,
    );
  }
}
