import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  /// فحص صلاحية الموقع
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // فحص إذا كانت خدمة الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض صلاحية الموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض صلاحية الموقع نهائياً');
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// الحصول على الموقع الحالي
  Future<LatLng> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation!;
    } catch (e) {
      // في حالة عدم الحصول على الموقع، استخدم موقع القاهرة كافتراضي
      _currentLocation = const LatLng(30.0444, 31.2357);
      return _currentLocation!;
    }
  }

  /// مراقبة تغيير الموقع
  Stream<LatLng> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation!;
    });
  }

  /// حساب المسافة بين نقطتين (بالمتر)
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// فحص إذا كان الموقع داخل نطاق معين (بالكيلومتر)
  bool isWithinRadius(LatLng center, LatLng point, double radiusKm) {
    final distance = calculateDistance(center, point);
    return distance <= (radiusKm * 1000);
  }
}
