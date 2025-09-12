import 'package:equatable/equatable.dart';

enum PermissionType {
  location,
  camera,
  storage,
  notification,
  microphone,
  contacts,
  calendar,
  photos,
}

enum PermissionStatus {
  granted,
  denied,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
}

class Permission extends Equatable {
  final PermissionType type;
  final PermissionStatus status;
  final String displayName;
  final String description;

  const Permission({
    required this.type,
    required this.status,
    required this.displayName,
    required this.description,
  });

  Permission copyWith({
    PermissionType? type,
    PermissionStatus? status,
    String? displayName,
    String? description,
  }) {
    return Permission(
      type: type ?? this.type,
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
    );
  }

  bool get isGranted => status == PermissionStatus.granted;
  bool get isDenied => status == PermissionStatus.denied;
  bool get isPermanentlyDenied => status == PermissionStatus.permanentlyDenied;

  @override
  List<Object?> get props => [type, status, displayName, description];
}
