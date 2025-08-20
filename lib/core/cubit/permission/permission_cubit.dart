import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/permission_service.dart';

part 'permission_state.dart';

class PermissionCubit
    extends Cubit<PermissionState> {
  final PermissionService _permissionService;

  PermissionCubit(this._permissionService)
      : super(PermissionInitial());

  Future<void> requestPermissions() async {
    emit(PermissionLoading());

    try {
      final hasPermissions =
          await _permissionService
              .requestAllPermissions();

      if (hasPermissions) {
        emit(PermissionGranted());
      } else {
        emit(PermissionDenied());
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> checkPermissions() async {
    emit(PermissionLoading());

    try {
      final hasPermissions =
          await _permissionService
              .checkAllPermissions();

      if (hasPermissions) {
        emit(PermissionGranted());
      } else {
        emit(PermissionDenied());
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> openSettings() async {
    await _permissionService.openAppSettings();
    await checkPermissions();
  }

  /// إعادة المحاولة
  Future<void> retry() async {
    await requestPermissions();
  }
}
