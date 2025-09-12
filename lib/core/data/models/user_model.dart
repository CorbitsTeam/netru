import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    super.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName:
          json['user_metadata']?['display_name'] ??
          json['user_metadata']?['full_name'],
      photoUrl: json['user_metadata']?['avatar_url'],
      emailVerifiedAt:
          json['email_confirmed_at'] != null
              ? DateTime.parse(json['email_confirmed_at'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['user_metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        if (displayName != null) 'display_name': displayName,
        if (photoUrl != null) 'avatar_url': photoUrl,
        ...?metadata,
      },
      'email_confirmed_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      emailVerifiedAt: user.emailVerifiedAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      metadata: user.metadata,
    );
  }
}
