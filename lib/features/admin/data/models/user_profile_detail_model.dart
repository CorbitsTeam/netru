import '../../domain/entities/user_profile_detail_entity.dart';
import '../../domain/entities/identity_document_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import 'identity_document_model.dart';
import 'report_summary_model.dart';

class UserProfileDetailModel extends UserProfileDetailEntity {
  const UserProfileDetailModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.nationalId,
    super.passportNumber,
    required super.userType,
    super.role,
    super.phone,
    super.governorate,
    super.city,
    super.district,
    super.address,
    super.nationality,
    super.profileImage,
    required super.verificationStatus,
    super.verifiedAt,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
    super.isActive = true,
    super.suspensionReason,
    super.suspendedAt,
    super.identityDocuments = const [],
    super.reports = const [],
    super.totalReportsCount = 0,
    super.pendingReportsCount = 0,
    super.resolvedReportsCount = 0,
    super.permissions = const [],
    super.activityStats = const {},
  });

  factory UserProfileDetailModel.fromJson(Map<String, dynamic> json) {
    return UserProfileDetailModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      userType: json['user_type'] ?? 'citizen',
      role: json['role'],
      phone: json['phone'],
      governorate: json['governorate'],
      city: json['city'],
      district: json['district'],
      address: json['address'],
      nationality: json['nationality'],
      profileImage: json['profile_image'],
      verificationStatus: json['verification_status'] ?? 'unverified',
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLoginAt:
          json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'])
              : null,
      isActive: json['is_active'] ?? true,
      suspensionReason: json['suspension_reason'],
      suspendedAt:
          json['suspended_at'] != null
              ? DateTime.parse(json['suspended_at'])
              : null,
      identityDocuments:
          json['identity_documents'] != null
              ? (json['identity_documents'] as List)
                  .map((doc) => IdentityDocumentModel.fromJson(doc))
                  .cast<IdentityDocumentEntity>()
                  .toList()
              : [],
      reports:
          json['reports'] != null
              ? (json['reports'] as List)
                  .map((report) => ReportSummaryModel.fromJson(report))
                  .cast<ReportSummaryEntity>()
                  .toList()
              : [],
      totalReportsCount: json['total_reports_count'] ?? 0,
      pendingReportsCount: json['pending_reports_count'] ?? 0,
      resolvedReportsCount: json['resolved_reports_count'] ?? 0,
      permissions:
          json['permissions'] != null
              ? List<String>.from(json['permissions'])
              : [],
      activityStats: json['activity_stats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'user_type': userType,
      'role': role,
      'phone': phone,
      'governorate': governorate,
      'city': city,
      'district': district,
      'address': address,
      'nationality': nationality,
      'profile_image': profileImage,
      'verification_status': verificationStatus,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
      'suspension_reason': suspensionReason,
      'suspended_at': suspendedAt?.toIso8601String(),
      'identity_documents':
          identityDocuments
              .map(
                (doc) =>
                    IdentityDocumentModel(
                      id: doc.id,
                      userId: doc.userId,
                      docType: doc.docType,
                      frontImageUrl: doc.frontImageUrl,
                      backImageUrl: doc.backImageUrl,
                      uploadedAt: doc.uploadedAt,
                      createdAt: doc.createdAt,
                    ).toJson(),
              )
              .toList(),
      'reports':
          reports
              .map(
                (report) =>
                    ReportSummaryModel(
                      id: report.id,
                      title: report.title,
                      description: report.description,
                      status: report.status,
                      priority: report.priority,
                      categoryName: report.categoryName,
                      governorate: report.governorate,
                      city: report.city,
                      createdAt: report.createdAt,
                      updatedAt: report.updatedAt,
                      assignedToName: report.assignedToName,
                      mediaCount: report.mediaCount,
                      commentsCount: report.commentsCount,
                    ).toJson(),
              )
              .toList(),
      'total_reports_count': totalReportsCount,
      'pending_reports_count': pendingReportsCount,
      'resolved_reports_count': resolvedReportsCount,
      'permissions': permissions,
      'activity_stats': activityStats,
    };
  }
}
