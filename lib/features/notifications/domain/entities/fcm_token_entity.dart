import 'package:equatable/equatable.dart';

enum DeviceType { android, ios, web }

class FcmTokenEntity extends Equatable {
  final String id;
  final String userId;
  final String fcmToken;
  final DeviceType? deviceType;
  final String? deviceId;
  final String? appVersion;
  final bool isActive;
  final DateTime lastUsed;
  final DateTime createdAt;

  const FcmTokenEntity({
    required this.id,
    required this.userId,
    required this.fcmToken,
    this.deviceType,
    this.deviceId,
    this.appVersion,
    this.isActive = true,
    required this.lastUsed,
    required this.createdAt,
  });

  FcmTokenEntity copyWith({
    String? id,
    String? userId,
    String? fcmToken,
    DeviceType? deviceType,
    String? deviceId,
    String? appVersion,
    bool? isActive,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return FcmTokenEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceType: deviceType ?? this.deviceType,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      isActive: isActive ?? this.isActive,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fcmToken,
    deviceType,
    deviceId,
    appVersion,
    isActive,
    lastUsed,
    createdAt,
  ];
}
