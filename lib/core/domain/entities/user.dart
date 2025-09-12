import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    emailVerifiedAt,
    createdAt,
    updatedAt,
    metadata,
  ];
}
