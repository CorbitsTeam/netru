import 'package:equatable/equatable.dart';

enum UserType { citizen, foreigner }

enum VerificationStatus { pending, verified, rejected }

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
  final VerificationStatus verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.verificationStatus = VerificationStatus.pending,
    this.createdAt,
    this.updatedAt,
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
    verificationStatus,
    createdAt,
    updatedAt,
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
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
