import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
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
    super.isActive = true,
    super.lastLoginAt,
    super.reportCount = 0,
    super.permissions = const [],
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      userType: AdminUserTypeExtension.fromString(json['user_type']),
      role: AdminRoleExtension.fromString(json['role']),
      phone: json['phone'],
      governorate: json['governorate'],
      city: json['city'],
      district: json['district'],
      address: json['address'],
      nationality: json['nationality'],
      profileImage: json['profile_image'],
      verificationStatus: _parseVerificationStatus(json['verification_status']),
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      lastLoginAt:
          json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'])
              : null,
      reportCount: json['report_count'] ?? 0,
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'user_type': userType.value,
      'role': role?.value,
      'phone': phone,
      'governorate': governorate,
      'city': city,
      'district': district,
      'address': address,
      'nationality': nationality,
      'profile_image': profileImage,
      'verification_status': verificationStatus.toString().split('.').last,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'report_count': reportCount,
      'permissions': permissions,
    };
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unverified;
    }
  }
}
