part of 'permission_cubit.dart';

abstract class PermissionState {}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionGranted extends PermissionState {}

class PermissionDenied extends PermissionState {}

class PermissionError extends PermissionState {
  final String message;
  PermissionError(this.message);
}
