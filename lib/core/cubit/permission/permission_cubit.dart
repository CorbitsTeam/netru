import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission.dart';
import '../../domain/usecases/permission_usecases.dart';
import '../../domain/usecases/usecase.dart';
import '../../services/logger_service.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  final CheckPermissionUseCase _checkPermissionUseCase;
  final RequestPermissionUseCase _requestPermissionUseCase;
  final RequestMultiplePermissionsUseCase _requestMultiplePermissionsUseCase;
  final OpenAppSettingsUseCase _openAppSettingsUseCase;
  final GetAllPermissionsStatusUseCase _getAllPermissionsStatusUseCase;
  final LoggerService _logger = LoggerService();

  PermissionCubit({
    required CheckPermissionUseCase checkPermissionUseCase,
    required RequestPermissionUseCase requestPermissionUseCase,
    required RequestMultiplePermissionsUseCase
    requestMultiplePermissionsUseCase,
    required OpenAppSettingsUseCase openAppSettingsUseCase,
    required GetAllPermissionsStatusUseCase getAllPermissionsStatusUseCase,
  }) : _checkPermissionUseCase = checkPermissionUseCase,
       _requestPermissionUseCase = requestPermissionUseCase,
       _requestMultiplePermissionsUseCase = requestMultiplePermissionsUseCase,
       _openAppSettingsUseCase = openAppSettingsUseCase,
       _getAllPermissionsStatusUseCase = getAllPermissionsStatusUseCase,
       super(PermissionInitial());

  Future<void> checkPermission(PermissionType type) async {
    try {
      emit(PermissionLoading());
      _logger.logInfo('🔒 Checking permission: ${type.toString()}');

      final result = await _checkPermissionUseCase(type);
      result.fold(
        (failure) {
          _logger.logError('❌ Permission check failed: ${failure.message}');
          emit(PermissionError(failure.message));
        },
        (permission) {
          _logger.logInfo(
            '✅ Permission check successful: ${permission.displayName} - ${permission.status}',
          );
          emit(PermissionChecked(permission));
        },
      );
    } catch (e) {
      _logger.logError('❌ Unexpected error in checkPermission', e);
      emit(PermissionError('An unexpected error occurred'));
    }
  }

  Future<void> requestPermission(PermissionType type) async {
    try {
      emit(PermissionLoading());
      _logger.logInfo('🔒 Requesting permission: ${type.toString()}');

      final result = await _requestPermissionUseCase(type);
      result.fold(
        (failure) {
          _logger.logError('❌ Permission request failed: ${failure.message}');
          emit(PermissionError(failure.message));
        },
        (permission) {
          if (permission.isGranted) {
            _logger.logInfo('✅ Permission granted: ${permission.displayName}');
            emit(PermissionGranted(permission));
          } else {
            _logger.logWarning(
              '❌ Permission denied: ${permission.displayName}',
            );
            emit(PermissionDenied(permission));
          }
        },
      );
    } catch (e) {
      _logger.logError('❌ Unexpected error in requestPermission', e);
      emit(PermissionError('An unexpected error occurred'));
    }
  }

  Future<void> requestMultiplePermissions(List<PermissionType> types) async {
    try {
      emit(PermissionLoading());
      _logger.logInfo(
        '🔒 Requesting multiple permissions: ${types.map((e) => e.toString()).join(', ')}',
      );

      final result = await _requestMultiplePermissionsUseCase(types);
      result.fold(
        (failure) {
          _logger.logError(
            '❌ Multiple permissions request failed: ${failure.message}',
          );
          emit(PermissionError(failure.message));
        },
        (permissions) {
          final granted = permissions.where((p) => p.isGranted).toList();
          final denied = permissions.where((p) => !p.isGranted).toList();

          _logger.logInfo(
            '✅ Multiple permissions result: ${granted.length} granted, ${denied.length} denied',
          );
          emit(MultiplePermissionsResult(granted, denied));
        },
      );
    } catch (e) {
      _logger.logError('❌ Unexpected error in requestMultiplePermissions', e);
      emit(PermissionError('An unexpected error occurred'));
    }
  }

  Future<void> openAppSettings() async {
    try {
      _logger.logInfo('🔧 Opening app settings');

      final result = await _openAppSettingsUseCase(NoParams());
      result.fold(
        (failure) {
          _logger.logError('❌ Failed to open app settings: ${failure.message}');
          emit(PermissionError(failure.message));
        },
        (success) {
          _logger.logInfo('✅ App settings opened successfully');
          // Don't emit a new state here as the user will return to the app
        },
      );
    } catch (e) {
      _logger.logError('❌ Unexpected error in openAppSettings', e);
      emit(PermissionError('An unexpected error occurred'));
    }
  }

  Future<void> getAllPermissionsStatus() async {
    try {
      emit(PermissionLoading());
      _logger.logInfo('🔒 Getting all permissions status');

      final result = await _getAllPermissionsStatusUseCase(NoParams());
      result.fold(
        (failure) {
          _logger.logError(
            '❌ Failed to get all permissions status: ${failure.message}',
          );
          emit(PermissionError(failure.message));
        },
        (permissions) {
          _logger.logInfo(
            '✅ All permissions status retrieved: ${permissions.length} permissions',
          );
          emit(AllPermissionsStatus(permissions));
        },
      );
    } catch (e) {
      _logger.logError('❌ Unexpected error in getAllPermissionsStatus', e);
      emit(PermissionError('An unexpected error occurred'));
    }
  }

  // Helper methods for quick permission checks
  Future<void> requestLocationPermission() async {
    await requestPermission(PermissionType.location);
  }

  Future<void> requestCameraPermission() async {
    await requestPermission(PermissionType.camera);
  }

  Future<void> requestStoragePermission() async {
    await requestPermission(PermissionType.storage);
  }

  Future<void> requestNotificationPermission() async {
    await requestPermission(PermissionType.notification);
  }

  Future<void> requestEssentialPermissions() async {
    await requestMultiplePermissions([
      PermissionType.location,
      PermissionType.camera,
      PermissionType.storage,
      PermissionType.notification,
    ]);
  }

  // Backward compatibility methods
  Future<void> requestPermissions() async {
    await requestEssentialPermissions();
  }

  Future<void> checkPermissions() async {
    await getAllPermissionsStatus();
  }

  Future<void> openSettings() async {
    await openAppSettings();
    await getAllPermissionsStatus();
  }

  Future<void> retry() async {
    await requestEssentialPermissions();
  }
}
