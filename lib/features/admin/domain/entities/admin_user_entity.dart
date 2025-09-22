import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? nationalId;
  final String? passportNumber;
  final AdminUserType userType;
  final AdminRole? role;
  final String? phone;
  final String? governorate;
  final String? city;
  final String? district;
  final String? address;
  final String? nationality;
  final String? profileImage;
  final VerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final int reportCount;
  final List<String> permissions;

  const AdminUserEntity({
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
    this.reportCount = 0,
    this.permissions = const [],
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
    reportCount,
    permissions,
  ];

  AdminUserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nationalId,
    String? passportNumber,
    AdminUserType? userType,
    AdminRole? role,
    String? phone,
    String? governorate,
    String? city,
    String? district,
    String? address,
    String? nationality,
    String? profileImage,
    VerificationStatus? verificationStatus,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    int? reportCount,
    List<String>? permissions,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      passportNumber: passportNumber ?? this.passportNumber,
      userType: userType ?? this.userType,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      reportCount: reportCount ?? this.reportCount,
      permissions: permissions ?? this.permissions,
    );
  }
}

enum AdminUserType { citizen, foreigner, admin }

enum AdminRole { superAdmin, admin, moderator, investigator, dataAnalyst }

enum VerificationStatus { unverified, pending, verified, rejected }

extension AdminUserTypeExtension on AdminUserType {
  String get value {
    switch (this) {
      case AdminUserType.citizen:
        return 'citizen';
      case AdminUserType.foreigner:
        return 'foreigner';
      case AdminUserType.admin:
        return 'admin';
    }
  }

  String get arabicName {
    switch (this) {
      case AdminUserType.citizen:
        return 'مواطن';
      case AdminUserType.foreigner:
        return 'أجنبي';
      case AdminUserType.admin:
        return 'مدير';
    }
  }

  static AdminUserType fromString(String value) {
    switch (value) {
      case 'citizen':
        return AdminUserType.citizen;
      case 'foreigner':
        return AdminUserType.foreigner;
      case 'admin':
        return AdminUserType.admin;
      default:
        return AdminUserType.citizen;
    }
  }
}

extension AdminRoleExtension on AdminRole {
  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.admin:
        return 'admin';
      case AdminRole.moderator:
        return 'moderator';
      case AdminRole.investigator:
        return 'investigator';
      case AdminRole.dataAnalyst:
        return 'data_analyst';
    }
  }

  String get arabicName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'مدير عام';
      case AdminRole.admin:
        return 'مدير';
      case AdminRole.moderator:
        return 'مشرف';
      case AdminRole.investigator:
        return 'محقق';
      case AdminRole.dataAnalyst:
        return 'محلل بيانات';
    }
  }

  static AdminRole? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'moderator':
        return AdminRole.moderator;
      case 'investigator':
        return AdminRole.investigator;
      case 'data_analyst':
        return AdminRole.dataAnalyst;
      default:
        return null;
    }
  }
}
