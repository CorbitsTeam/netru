import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final UserType userType;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
    required this.userType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    profileImage,
    userType,
    createdAt,
  ];
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
    required super.createdAt,
    required this.nationalId,
    this.address,
  }) : super(userType: UserType.egyptian);

  @override
  List<Object?> get props => [...super.props, nationalId, address];
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
    required super.createdAt,
    required this.passportNumber,
    required this.nationality,
  }) : super(userType: UserType.foreigner);

  @override
  List<Object?> get props => [...super.props, passportNumber, nationality];
}
