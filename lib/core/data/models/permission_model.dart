import '../../domain/entities/permission.dart';

class PermissionModel extends Permission {
  const PermissionModel({
    required super.type,
    required super.status,
    required super.displayName,
    required super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      type: PermissionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PermissionType.location,
      ),
      status: PermissionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PermissionStatus.denied,
      ),
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'status': status.toString(),
      'displayName': displayName,
      'description': description,
    };
  }

  factory PermissionModel.fromEntity(Permission permission) {
    return PermissionModel(
      type: permission.type,
      status: permission.status,
      displayName: permission.displayName,
      description: permission.description,
    );
  }
}
