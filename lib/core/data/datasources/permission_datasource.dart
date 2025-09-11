import 'package:permission_handler/permission_handler.dart' as ph;
import '../../domain/entities/permission.dart' as domain;
import '../models/permission_model.dart';
import '../../services/logger_service.dart';

abstract class PermissionDataSource {
  Future<PermissionModel> checkPermission(domain.PermissionType type);
  Future<PermissionModel> requestPermission(domain.PermissionType type);
  Future<List<PermissionModel>> requestMultiplePermissions(
    List<domain.PermissionType> types,
  );
  Future<bool> openAppSettings();
  Future<List<PermissionModel>> getAllPermissionsStatus();
}

class PermissionDataSourceImpl implements PermissionDataSource {
  final LoggerService _logger = LoggerService();

  ph.Permission _mapToPhPermission(domain.PermissionType type) {
    switch (type) {
      case domain.PermissionType.location:
        return ph.Permission.location;
      case domain.PermissionType.camera:
        return ph.Permission.camera;
      case domain.PermissionType.storage:
        return ph.Permission.storage;
      case domain.PermissionType.notification:
        return ph.Permission.notification;
      case domain.PermissionType.microphone:
        return ph.Permission.microphone;
      case domain.PermissionType.contacts:
        return ph.Permission.contacts;
      case domain.PermissionType.calendar:
        return ph.Permission.calendarWriteOnly;
      case domain.PermissionType.photos:
        return ph.Permission.photos;
    }
  }

  domain.PermissionStatus _mapFromPhStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return domain.PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return domain.PermissionStatus.denied;
      case ph.PermissionStatus.restricted:
        return domain.PermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return domain.PermissionStatus.limited;
      case ph.PermissionStatus.permanentlyDenied:
        return domain.PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.provisional:
        return domain.PermissionStatus.provisional;
    }
  }

  String _getDisplayName(domain.PermissionType type) {
    switch (type) {
      case domain.PermissionType.location:
        return 'Location';
      case domain.PermissionType.camera:
        return 'Camera';
      case domain.PermissionType.storage:
        return 'Storage';
      case domain.PermissionType.notification:
        return 'Notifications';
      case domain.PermissionType.microphone:
        return 'Microphone';
      case domain.PermissionType.contacts:
        return 'Contacts';
      case domain.PermissionType.calendar:
        return 'Calendar';
      case domain.PermissionType.photos:
        return 'Photos';
    }
  }

  String _getDescription(domain.PermissionType type) {
    switch (type) {
      case domain.PermissionType.location:
        return 'Access to your device location for location-based features';
      case domain.PermissionType.camera:
        return 'Access to camera for taking photos and videos';
      case domain.PermissionType.storage:
        return 'Access to device storage for saving files';
      case domain.PermissionType.notification:
        return 'Permission to send notifications';
      case domain.PermissionType.microphone:
        return 'Access to microphone for recording audio';
      case domain.PermissionType.contacts:
        return 'Access to contacts for enhanced features';
      case domain.PermissionType.calendar:
        return 'Access to calendar for scheduling features';
      case domain.PermissionType.photos:
        return 'Access to photos for image selection';
    }
  }

  @override
  Future<PermissionModel> checkPermission(domain.PermissionType type) async {
    try {
      _logger.logPermissionRequest(_getDisplayName(type));

      final permission = _mapToPhPermission(type);
      final status = await permission.status;

      final result = PermissionModel(
        type: type,
        status: _mapFromPhStatus(status),
        displayName: _getDisplayName(type),
        description: _getDescription(type),
      );

      _logger.logInfo(
        '✅ Permission Check Complete: ${_getDisplayName(type)} - ${result.status}',
      );
      return result;
    } catch (e) {
      _logger.logError(
        '❌ Permission Check Failed: ${_getDisplayName(type)}',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<PermissionModel> requestPermission(domain.PermissionType type) async {
    try {
      _logger.logPermissionRequest(_getDisplayName(type));

      final permission = _mapToPhPermission(type);
      final status = await permission.request();

      final result = PermissionModel(
        type: type,
        status: _mapFromPhStatus(status),
        displayName: _getDisplayName(type),
        description: _getDescription(type),
      );

      if (result.isGranted) {
        _logger.logPermissionGranted(_getDisplayName(type));
      } else {
        _logger.logPermissionDenied(_getDisplayName(type));
      }

      return result;
    } catch (e) {
      _logger.logError(
        '❌ Permission Request Failed: ${_getDisplayName(type)}',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<List<PermissionModel>> requestMultiplePermissions(
    List<domain.PermissionType> types,
  ) async {
    try {
      final permissions = types.map(_mapToPhPermission).toList();
      final statuses = await permissions.request();

      final results = <PermissionModel>[];

      for (int i = 0; i < types.length; i++) {
        final type = types[i];
        final status = statuses[permissions[i]];

        final result = PermissionModel(
          type: type,
          status: _mapFromPhStatus(status!),
          displayName: _getDisplayName(type),
          description: _getDescription(type),
        );

        results.add(result);

        if (result.isGranted) {
          _logger.logPermissionGranted(_getDisplayName(type));
        } else {
          _logger.logPermissionDenied(_getDisplayName(type));
        }
      }

      return results;
    } catch (e) {
      _logger.logError('❌ Multiple Permissions Request Failed', e);
      rethrow;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      _logger.logInfo('🔧 Opening App Settings');
      final result = await ph.openAppSettings();
      _logger.logInfo('✅ App Settings Opened: $result');
      return result;
    } catch (e) {
      _logger.logError('❌ Failed to Open App Settings', e);
      rethrow;
    }
  }

  @override
  Future<List<PermissionModel>> getAllPermissionsStatus() async {
    try {
      const allTypes = domain.PermissionType.values;
      final results = <PermissionModel>[];

      for (final type in allTypes) {
        final result = await checkPermission(type);
        results.add(result);
      }

      return results;
    } catch (e) {
      _logger.logError('❌ Failed to Get All Permissions Status', e);
      rethrow;
    }
  }
}
