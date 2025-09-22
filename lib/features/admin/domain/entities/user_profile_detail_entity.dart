import 'package:equatable/equatable.dart';
import 'identity_document_entity.dart';
import 'report_summary_entity.dart';

class UserProfileDetailEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? nationalId;
  final String? passportNumber;
  final String userType;
  final String? role;
  final String? phone;
  final String? governorate;
  final String? city;
  final String? district;
  final String? address;
  final String? nationality;
  final String? profileImage;
  final String verificationStatus;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? suspensionReason;
  final DateTime? suspendedAt;

  // Additional data
  final List<IdentityDocumentEntity> identityDocuments;
  final List<ReportSummaryEntity> reports;
  final int totalReportsCount;
  final int pendingReportsCount;
  final int resolvedReportsCount;
  final List<String> permissions;
  final Map<String, dynamic> activityStats;

  const UserProfileDetailEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.nationalId,
    this.passportNumber,
    required this.userType,
    this.role,
    this.phone,
    this.governorate,
    this.city,
    this.district,
    this.address,
    this.nationality,
    this.profileImage,
    required this.verificationStatus,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isActive = true,
    this.suspensionReason,
    this.suspendedAt,
    this.identityDocuments = const [],
    this.reports = const [],
    this.totalReportsCount = 0,
    this.pendingReportsCount = 0,
    this.resolvedReportsCount = 0,
    this.permissions = const [],
    this.activityStats = const {},
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    nationalId,
    passportNumber,
    userType,
    role,
    phone,
    governorate,
    city,
    district,
    address,
    nationality,
    profileImage,
    verificationStatus,
    verifiedAt,
    createdAt,
    updatedAt,
    lastLoginAt,
    isActive,
    suspensionReason,
    suspendedAt,
    identityDocuments,
    reports,
    totalReportsCount,
    pendingReportsCount,
    resolvedReportsCount,
    permissions,
    activityStats,
  ];
}
