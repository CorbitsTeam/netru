import 'package:equatable/equatable.dart';

enum DocumentType { nationalId, passport }

enum DocumentStatus { pending, verified, rejected }

class IdentityDocument extends Equatable {
  final String id;
  final String userId;
  final DocumentType type;
  final String documentNumber;
  final String fullName;
  final String dateOfBirth;
  final String? nationality;
  final String? expiryDate;
  final String? issueDate;
  final String? placeOfBirth;
  final String imageUrl;
  final String? extractedDataJson;
  final DocumentStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  const IdentityDocument({
    required this.id,
    required this.userId,
    required this.type,
    required this.documentNumber,
    required this.fullName,
    required this.dateOfBirth,
    this.nationality,
    this.expiryDate,
    this.issueDate,
    this.placeOfBirth,
    required this.imageUrl,
    this.extractedDataJson,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    documentNumber,
    fullName,
    dateOfBirth,
    nationality,
    expiryDate,
    issueDate,
    placeOfBirth,
    imageUrl,
    extractedDataJson,
    status,
    createdAt,
    verifiedAt,
    rejectionReason,
  ];

  IdentityDocument copyWith({
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
    return IdentityDocument(
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

  bool get isVerified => status == DocumentStatus.verified;
  bool get isPending => status == DocumentStatus.pending;
  bool get isRejected => status == DocumentStatus.rejected;
}
