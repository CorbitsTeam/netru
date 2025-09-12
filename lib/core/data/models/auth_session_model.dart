import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresIn,
    required super.expiresAt,
    required super.userId,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 3600,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (json['expires_at'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) *
            1000,
      ),
      userId: json['user']?['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'user': {'id': userId},
    };
  }

  factory AuthSessionModel.fromEntity(AuthSession session) {
    return AuthSessionModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      tokenType: session.tokenType,
      expiresIn: session.expiresIn,
      expiresAt: session.expiresAt,
      userId: session.userId,
    );
  }
}
