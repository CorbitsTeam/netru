import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.email,
    required super.fullName,
    super.nationalId,
    super.passportNumber,
    required super.userType,
    super.phone,
    super.governorateId,
    super.governorateName,
    super.cityId,
    super.cityName,
    super.districtId,
    super.districtName,
    super.address,
    super.dateOfBirth,
    super.verificationStatus,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? '',
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      userType: _parseUserType(json['user_type']),
      phone: json['phone'],
      governorateId: json['governorate'],
      governorateName: json['governorate_name'],
      cityId: json['city'],
      cityName: json['city_name'],
      districtId: json['district'],
      districtName: json['district_name'],
      address: json['address'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.tryParse(json['date_of_birth'])
              : null,
      verificationStatus: _parseVerificationStatus(json['verification_status']),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'user_type': userType.name,
      'phone': phone,
      'governorate': governorateId,
      'city': cityId,
      'district': districtId,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'verification_status': verificationStatus.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{
      'full_name': fullName,
      'user_type': userType.name,
      'verification_status': verificationStatus.name,
    };

    if (email != null) json['email'] = email;
    if (nationalId != null) json['national_id'] = nationalId;
    if (passportNumber != null) json['passport_number'] = passportNumber;
    if (phone != null) json['phone'] = phone;
    if (governorateId != null) json['governorate'] = governorateId;
    if (cityId != null) json['city'] = cityId;
    if (districtId != null) json['district'] = districtId;
    if (address != null) json['address'] = address;
    // Remove date_of_birth as it's not in the database schema
    // if (dateOfBirth != null)
    //   json['date_of_birth'] = dateOfBirth!.toIso8601String();

    return json;
  }

  static UserType _parseUserType(String? type) {
    switch (type) {
      case 'citizen':
        return UserType.citizen;
      case 'foreigner':
        return UserType.foreigner;
      default:
        return UserType.citizen;
    }
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      nationalId: entity.nationalId,
      passportNumber: entity.passportNumber,
      userType: entity.userType,
      phone: entity.phone,
      governorateId: entity.governorateId,
      governorateName: entity.governorateName,
      cityId: entity.cityId,
      cityName: entity.cityName,
      districtId: entity.districtId,
      districtName: entity.districtName,
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      verificationStatus: entity.verificationStatus,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
