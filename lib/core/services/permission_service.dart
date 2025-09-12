import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance =
      PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// طلب جميع الصلاحيات المطلوبة
  Future<bool> requestAllPermissions() async {
    try {
      // طلب صلاحية الموقع
      final locationPermission =
          await _requestLocationPermission();

      // يمكنك إضافة صلاحيات أخرى هنا
      // final cameraPermission = await Permission.camera.request();
      // final notificationPermission = await Permission.notification.request();

      return locationPermission;
    } catch (e) {
      print('خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  /// طلب صلاحية الموقع
  Future<bool>
      _requestLocationPermission() async {
    // التحقق من حالة الصلاحية الحالية
    PermissionStatus permission =
        await Permission.location.status;

    if (permission.isGranted) {
      return await _checkLocationService();
    }

    if (permission.isDenied) {
      // طلب الصلاحية
      permission =
          await Permission.location.request();

      if (permission.isGranted) {
        return await _checkLocationService();
      }
    }

    if (permission.isPermanentlyDenied) {
      // توجيه المستخدم لفتح الإعدادات
      await _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  /// التحقق من تفعيل خدمة الموقع
  Future<bool> _checkLocationService() async {
    bool serviceEnabled = await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      // طلب تفعيل خدمة الموقع
      return await _requestLocationService();
    }

    return true;
  }

  /// طلب تفعيل خدمة الموقع
  Future<bool> _requestLocationService() async {
    try {
      // محاولة فتح إعدادات الموقع
      bool opened =
          await Geolocator.openLocationSettings();

      if (opened) {
        // انتظار قليل ثم التحقق مرة أخرى
        await Future.delayed(
            const Duration(seconds: 2));
        return await Geolocator
            .isLocationServiceEnabled();
      }

      return false;
    } catch (e) {
      print('خطأ في فتح إعدادات الموقع: $e');
      return false;
    }
  }

  /// عرض dialog عند رفض الصلاحية نهائياً
  Future<void>
      _showPermissionDeniedDialog() async {
    // سيتم تنفيذ هذا من خلال الـ UI layer
    await openAppSettings();
  }

  /// التحقق من جميع الصلاحيات
  Future<bool> checkAllPermissions() async {
    final locationGranted =
        await Permission.location.isGranted;
    final locationServiceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    return locationGranted &&
        locationServiceEnabled;
  }

  /// الحصول على الموقع الحالي (للاختبار)
  Future<Position?> getCurrentLocation() async {
    try {
      if (await checkAllPermissions()) {
        return await Geolocator
            .getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      return null;
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      return null;
    }
  }

  /// فتح إعدادات التطبيق
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
