part of 'permission_cubit.dart';

abstract class PermissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionGranted extends PermissionState {
  final Permission? permission;

  PermissionGranted([this.permission]);

  @override
  List<Object?> get props => [permission];
}

class PermissionDenied extends PermissionState {
  final Permission? permission;

  PermissionDenied([this.permission]);

  @override
  List<Object?> get props => [permission];
}

class PermissionChecked extends PermissionState {
  final Permission permission;

  PermissionChecked(this.permission);

  @override
  List<Object?> get props => [permission];
}

class MultiplePermissionsResult extends PermissionState {
  final List<Permission> granted;
  final List<Permission> denied;

  MultiplePermissionsResult(this.granted, this.denied);

  @override
  List<Object?> get props => [granted, denied];
}

class AllPermissionsStatus extends PermissionState {
  final List<Permission> permissions;

  AllPermissionsStatus(this.permissions);

  @override
  List<Object?> get props => [permissions];
}

class PermissionError extends PermissionState {
  final String message;

  PermissionError(this.message);

  @override
  List<Object?> get props => [message];
}
