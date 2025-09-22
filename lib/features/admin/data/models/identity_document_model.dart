import '../../domain/entities/identity_document_entity.dart';

class IdentityDocumentModel extends IdentityDocumentEntity {
  const IdentityDocumentModel({
    required super.id,
    required super.userId,
    required super.docType,
    super.frontImageUrl,
    super.backImageUrl,
    required super.uploadedAt,
    required super.createdAt,
  });

  factory IdentityDocumentModel.fromJson(Map<String, dynamic> json) {
    return IdentityDocumentModel(
      id: json['id'],
      userId: json['user_id'],
      docType: DocumentTypeExtension.fromString(json['doc_type']),
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'doc_type': docType.value,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
