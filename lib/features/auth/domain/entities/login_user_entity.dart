import 'package:equatable/equatable.dart';

enum UserType { citizen, foreigner, admin }

enum VerificationStatus { pending, verified, rejected }

class LoginUserEntity extends Equatable {
  final String id;
  final String fullName;
  final UserType userType;
  final String? nationalId;
  final String? passportNumber;
  final String? email;
  final String? phone;
  final String? address;
  final String? nationality;
  final String? profileImage;
  final VerificationStatus verificationStatus;

  const LoginUserEntity({
    required this.id,
    required this.fullName,
    required this.userType,
    this.nationalId,
    this.passportNumber,
    this.email,
    this.phone,
    this.address,
    this.nationality,
    this.profileImage,
    this.verificationStatus = VerificationStatus.pending,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    userType,
    nationalId,
    passportNumber,
    email,
    phone,
    address,
    nationality,
    profileImage,
    verificationStatus,
  ];

  LoginUserEntity copyWith({
    String? id,
    String? fullName,
    UserType? userType,
    String? nationalId,
    String? passportNumber,
    String? email,
    String? phone,
    String? address,
    String? nationality,
    String? profileImage,
    VerificationStatus? verificationStatus,
  }) {
    return LoginUserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      nationalId: nationalId ?? this.nationalId,
      passportNumber: passportNumber ?? this.passportNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
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
}
