import 'package:equatable/equatable.dart';

enum VerificationStatus { unverified, pending, verified, rejected }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final UserType userType;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
    required this.userType,
    this.verificationStatus = VerificationStatus.unverified,
    required this.createdAt,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    profileImage,
    userType,
    verificationStatus,
    createdAt,
    verifiedAt,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? profileImage,
    UserType? userType,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;
  bool get isPendingVerification =>
      verificationStatus == VerificationStatus.pending;
  bool get isUnverified => verificationStatus == VerificationStatus.unverified;
  bool get isRejected => verificationStatus == VerificationStatus.rejected;
}

enum UserType { egyptian, foreigner }

class CitizenEntity extends UserEntity {
  final String nationalId;
  final String? address;

  const CitizenEntity({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.profileImage,
    super.verificationStatus = VerificationStatus.unverified,
    required super.createdAt,
    super.verifiedAt,
    required this.nationalId,
    this.address,
  }) : super(userType: UserType.egyptian);

  @override
  List<Object?> get props => [...super.props, nationalId, address];

  @override
  CitizenEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? profileImage,
    UserType? userType,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? nationalId,
    String? address,
  }) {
    return CitizenEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
    );
  }
}

class ForeignerEntity extends UserEntity {
  final String passportNumber;
  final String nationality;

  const ForeignerEntity({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.profileImage,
    super.verificationStatus = VerificationStatus.unverified,
    required super.createdAt,
    super.verifiedAt,
    required this.passportNumber,
    required this.nationality,
  }) : super(userType: UserType.foreigner);

  @override
  List<Object?> get props => [...super.props, passportNumber, nationality];

  @override
  ForeignerEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? profileImage,
    UserType? userType,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? passportNumber,
    String? nationality,
  }) {
    return ForeignerEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
    );
  }
}
