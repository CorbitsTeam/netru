import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.profileImage,
    required super.userType,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      userType: UserType.values.firstWhere(
        (type) => type.name == json['user_type'],
        orElse: () => UserType.egyptian,
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'profile_image': profileImage,
      'user_type': userType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CitizenModel extends CitizenEntity {
  const CitizenModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.profileImage,
    required super.createdAt,
    required super.nationalId,
    super.address,
  });

  factory CitizenModel.fromJson(Map<String, dynamic> json) {
    return CitizenModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      nationalId: json['national_id'] ?? '',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'profile_image': profileImage,
      'user_type': userType.name,
      'created_at': createdAt.toIso8601String(),
      'national_id': nationalId,
      'address': address,
    };
  }
}

class ForeignerModel extends ForeignerEntity {
  const ForeignerModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.profileImage,
    required super.createdAt,
    required super.passportNumber,
    required super.nationality,
  });

  factory ForeignerModel.fromJson(Map<String, dynamic> json) {
    return ForeignerModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      passportNumber: json['passport_number'] ?? '',
      nationality: json['nationality'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'profile_image': profileImage,
      'user_type': userType.name,
      'created_at': createdAt.toIso8601String(),
      'passport_number': passportNumber,
      'nationality': nationality,
    };
  }
}
