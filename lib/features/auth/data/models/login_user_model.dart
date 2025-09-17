import '../../domain/entities/login_user_entity.dart';

class LoginUserModel extends LoginUserEntity {
  const LoginUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.userType,
    super.nationalId,
    super.passportNumber,
    super.role,
    super.phone,
    super.governorate,
    super.city,
    super.district,
    super.address,
    super.nationality,
    super.profileImage,
    super.verificationStatus,
    super.createdAt,
    super.modifiedAt,
    super.verifiedAt,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      userType: _parseUserType(json['user_type']),
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      role: json['role'],
      phone: json['phone'],
      governorate: json['governorate'],
      city: json['city'],
      district: json['district'],
      address: json['address'],
      nationality: json['nationality'],
      profileImage: json['profile_image'],
      verificationStatus: _parseVerificationStatus(json['verification_status']),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      modifiedAt:
          json['modified_at'] != null
              ? DateTime.tryParse(json['modified_at'])
              : null,
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.tryParse(json['verified_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType.name,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'role': role,
      'phone': phone,
      'governorate': governorate,
      'city': city,
      'district': district,
      'address': address,
      'nationality': nationality,
      'profile_image': profileImage,
      'verification_status': verificationStatus.name,
      'created_at': createdAt?.toIso8601String(),
      'modified_at': modifiedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  static UserType _parseUserType(String? type) {
    switch (type?.toLowerCase()) {
      case 'citizen':
        return UserType.citizen;
      case 'foreigner':
        return UserType.foreigner;
      case 'admin':
        return UserType.admin;
      default:
        return UserType.citizen; // Default fallback
    }
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'unverified':
        return VerificationStatus.unverified;
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unverified; // Default fallback
    }
  }

  factory LoginUserModel.fromEntity(LoginUserEntity entity) {
    return LoginUserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      userType: entity.userType,
      nationalId: entity.nationalId,
      passportNumber: entity.passportNumber,
      role: entity.role,
      phone: entity.phone,
      governorate: entity.governorate,
      city: entity.city,
      district: entity.district,
      address: entity.address,
      nationality: entity.nationality,
      profileImage: entity.profileImage,
      verificationStatus: entity.verificationStatus,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
      verifiedAt: entity.verifiedAt,
    );
  }
}
