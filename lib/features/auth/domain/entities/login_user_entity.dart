import 'package:equatable/equatable.dart';

enum UserType { citizen, foreigner, admin }

enum VerificationStatus { unverified, pending, verified, rejected }

class LoginUserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserType userType;
  final String? nationalId;
  final String? passportNumber;
  final String? role;
  final String? phone;
  final String? governorate;
  final String? city;
  final String? district;
  final String? address;
  final String? nationality;
  final String? profileImage;
  final VerificationStatus verificationStatus;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final DateTime? verifiedAt;

  const LoginUserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    this.nationalId,
    this.passportNumber,
    this.role,
    this.phone,
    this.governorate,
    this.city,
    this.district,
    this.address,
    this.nationality,
    this.profileImage,
    this.verificationStatus = VerificationStatus.unverified,
    this.createdAt,
    this.modifiedAt,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    userType,
    nationalId,
    passportNumber,
    role,
    phone,
    governorate,
    city,
    district,
    address,
    nationality,
    profileImage,
    verificationStatus,
    createdAt,
    modifiedAt,
    verifiedAt,
  ];

  LoginUserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    UserType? userType,
    String? nationalId,
    String? passportNumber,
    String? role,
    String? phone,
    String? governorate,
    String? city,
    String? district,
    String? address,
    String? nationality,
    String? profileImage,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? verifiedAt,
  }) {
    return LoginUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      nationalId: nationalId ?? this.nationalId,
      passportNumber: passportNumber ?? this.passportNumber,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
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
          governorate,
          city,
          district,
          address,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isEmpty ? 'غير محدد' : parts.join(', ');
  }

  /// Get user's location as governorate and city
  String get location {
    final parts =
        [
          governorate,
          city,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isEmpty ? 'غير محدد' : parts.join(', ');
  }
}
