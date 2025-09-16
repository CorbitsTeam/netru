import '../../domain/entities/login_user_entity.dart';

class LoginUserModel extends LoginUserEntity {
  const LoginUserModel({
    required super.id,
    required super.fullName,
    required super.userType,
    super.nationalId,
    super.passportNumber,
    super.email,
    super.phone,
    super.address,
    super.nationality,
    super.profileImage,
    super.verificationStatus,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      userType: _parseUserType(json['user_type']),
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      nationality: json['nationality'],
      profileImage: json['profile_image'],
      verificationStatus: _parseVerificationStatus(json['verification_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'user_type': userType.name,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'email': email,
      'phone': phone,
      'address': address,
      'nationality': nationality,
      'profile_image': profileImage,
      'verification_status': verificationStatus.name,
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
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending; // Default fallback
    }
  }

  factory LoginUserModel.fromEntity(LoginUserEntity entity) {
    return LoginUserModel(
      id: entity.id,
      fullName: entity.fullName,
      userType: entity.userType,
      nationalId: entity.nationalId,
      passportNumber: entity.passportNumber,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      nationality: entity.nationality,
      profileImage: entity.profileImage,
      verificationStatus: entity.verificationStatus,
    );
  }
}
