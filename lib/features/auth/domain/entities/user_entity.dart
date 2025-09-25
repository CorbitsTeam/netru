import 'package:equatable/equatable.dart';

enum UserType { citizen, foreigner, admin }

enum VerificationStatus { unverified, pending, verified, rejected }

class UserEntity extends Equatable {
  final String? id;
  final String? email;
  final String fullName;
  final String? nationalId;
  final String? passportNumber;
  final UserType userType;
  final String? phone;
  final int? governorateId;
  final String? governorateName;
  final int? cityId;
  final String? cityName;
  final int? districtId;
  final String? districtName;
  final String? address;
  final DateTime? dateOfBirth;
  final String? role;
  final String? nationality;
  final String? profileImage;
  final VerificationStatus verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;

  const UserEntity({
    this.id,
    this.email,
    required this.fullName,
    this.nationalId,
    this.passportNumber,
    required this.userType,
    this.phone,
    this.governorateId,
    this.governorateName,
    this.cityId,
    this.cityName,
    this.districtId,
    this.districtName,
    this.address,
    this.dateOfBirth,
    this.role,
    this.nationality,
    this.profileImage,
    this.verificationStatus = VerificationStatus.pending,
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    nationalId,
    passportNumber,
    userType,
    phone,
    governorateId,
    cityId,
    districtId,
    address,
    dateOfBirth,
    role,
    nationality,
    profileImage,
    verificationStatus,
    createdAt,
    updatedAt,
    verifiedAt,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nationalId,
    String? passportNumber,
    UserType? userType,
    String? phone,
    int? governorateId,
    String? governorateName,
    int? cityId,
    String? cityName,
    int? districtId,
    String? districtName,
    String? address,
    DateTime? dateOfBirth,
    String? role,
    String? nationality,
    String? profileImage,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      passportNumber: passportNumber ?? this.passportNumber,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      governorateId: governorateId ?? this.governorateId,
      governorateName: governorateName ?? this.governorateName,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      nationality: nationality ?? this.nationality,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  /// Helper method to get the identifier based on user type
  String? get identifier {
    switch (userType) {
      case UserType.citizen:
        return nationalId;
      case UserType.foreigner:
        return passportNumber;
      case UserType.admin:
        return email;
    }
  }

  /// Helper method to determine if the user is an admin
  bool get isAdmin => userType == UserType.admin;

  /// Helper method to determine if the user is verified
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Get user's full address combining governorate, city, district, and address
  String get fullAddress {
    final parts =
        [
          governorateName,
          cityName,
          districtName,
          address,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isEmpty ? 'غير محدد' : parts.join(', ');
  }

  /// Get user's location as governorate and city
  String get location {
    final parts =
        [
          governorateName,
          cityName,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isEmpty ? 'غير محدد' : parts.join(', ');
  }
}
