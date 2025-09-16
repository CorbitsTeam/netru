import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionHelper {
  /// التحقق من صلاحية الموقع مع رسائل مفصلة
  static Future<LocationPermissionResult> checkLocationPermission() async {
    // التحقق من تفعيل خدمة الموقع أولاً
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult(
        isGranted: false,
        needsService: true,
        message: 'خدمة الموقع غير مفعلة',
      );
    }

    // التحقق من صلاحية الموقع
    LocationPermission permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionResult(
          isGranted: true,
          needsService: false,
          message: 'الصلاحية ممنوحة',
        );

      case LocationPermission.denied:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          canRequest: true,
          message: 'الصلاحية مرفوضة',
        );

      case LocationPermission.deniedForever:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          canRequest: false,
          message: 'الصلاحية مرفوضة نهائياً',
        );

      default:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          message: 'حالة غير معروفة',
        );
    }
  }

  /// طلب صلاحية الموقع
  static Future<LocationPermissionResult> requestLocationPermission() async {
    // التحقق من تفعيل الخدمة أولاً
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult(
        isGranted: false,
        needsService: true,
        message: 'يجب تفعيل خدمة الموقع أولاً',
      );
    }

    // طلب الصلاحية
    LocationPermission permission = await Geolocator.requestPermission();

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionResult(
          isGranted: true,
          needsService: false,
          message: 'تم منح الصلاحية بنجاح',
        );

      case LocationPermission.denied:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          canRequest: true,
          message: 'تم رفض الصلاحية',
        );

      case LocationPermission.deniedForever:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          canRequest: false,
          message: 'تم رفض الصلاحية نهائياً. يرجى فتح الإعدادات.',
        );

      default:
        return LocationPermissionResult(
          isGranted: false,
          needsService: false,
          message: 'فشل في طلب الصلاحية',
        );
    }
  }

  /// فتح إعدادات الموقع
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات الموقع: $e');
      return false;
    }
  }

  /// فتح إعدادات التطبيق
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
      return false;
    }
  }

  /// التحقق من جميع الصلاحيات المطلوبة
  static Future<bool> checkAllRequiredPermissions() async {
    final locationResult = await checkLocationPermission();

    // يمكنك إضافة صلاحيات أخرى هنا
    // final cameraGranted = await Permission.camera.isGranted;
    // final storageGranted = await Permission.storage.isGranted;

    return locationResult.isGranted;
  }

  /// عرض dialog تفسيري لسبب الحاجة للصلاحية
  static void showPermissionRationale(
    BuildContext context,
    String title,
    String message,
    VoidCallback onAccept,
    VoidCallback onDeny,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: onDeny, child: const Text('لا شكراً')),
              ElevatedButton(onPressed: onAccept, child: const Text('موافق')),
            ],
          ),
    );
  }
}

/// نتيجة فحص صلاحية الموقع
class LocationPermissionResult {
  final bool isGranted;
  final bool needsService;
  final bool canRequest;
  final String message;

  LocationPermissionResult({
    required this.isGranted,
    required this.needsService,
    this.canRequest = true,
    required this.message,
  });

  @override
  String toString() {
    return 'LocationPermissionResult(isGranted: $isGranted, needsService: $needsService, canRequest: $canRequest, message: $message)';
  }
}
