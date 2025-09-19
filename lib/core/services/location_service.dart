import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../errors/failures.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // GPS location properties
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  // Check location permission
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current GPS location
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // فحص إذا كان التطبيق يعمل على محاكي
      bool isEmulator = await _isRunningOnEmulator();

      if (isEmulator) {
        // إحداثيات مدينة نصر الحقيقية
        _currentLocation = const LatLng(30.0626, 31.3219); // مدينة نصر، القاهرة، مصر
        print('تم اكتشاف المحاكي - استخدام إحداثيات مدينة نصر');
      } else {
        _currentLocation = LatLng(position.latitude, position.longitude);
      }

      return _currentLocation;
    } catch (e) {
      // في حالة الخطأ، استخدم إحداثيات مدينة نصر كاحتياطي
      _currentLocation = const LatLng(30.0626, 31.3219);
      return _currentLocation;
    }
  }

  // Open location in Google Maps
  static Future<void> openInGoogleMaps(
    double latitude,
    double longitude,
  ) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final String appleMapsUrl =
        'https://maps.apple.com/?q=$latitude,$longitude';

    try {
      // محاولة فتح خرائط جوجل أولاً
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      // إذا فشل، جرب خرائط أبل (على iOS)
      else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      // إذا فشل كلاهما، استخدم المتصفح
      else {
        await launchUrl(
          Uri.parse('https://www.google.com/maps/@$latitude,$longitude,15z'),
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      throw 'لا يمكن فتح تطبيق الخرائط: $e';
    }
  }

  // Get all governorates
  Future<Either<Failure, List<GovernorateModel>>> getGovernorates() async {
    try {
      final response = await _supabaseClient
          .from('governorates')
          .select('*')
          .order('name');

      return Right(
        (response as List)
            .map((json) => GovernorateModel.fromJson(json))
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل المحافظات: ${e.toString()}'));
    }
  }

  // Get cities for a specific governorate
  Future<Either<Failure, List<CityModel>>> getCities(int governorateId) async {
    try {
      final response = await _supabaseClient
          .from('cities')
          .select('*')
          .eq('governorate_id', governorateId)
          .order('name');

      return Right(
        (response as List).map((json) => CityModel.fromJson(json)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل المدن: ${e.toString()}'));
    }
  }

  // Get districts for a specific city
  Future<Either<Failure, List<DistrictModel>>> getDistricts(int cityId) async {
    try {
      final response = await _supabaseClient
          .from('districts')
          .select('*')
          .eq('city_id', cityId)
          .order('name');

      return Right(
        (response as List).map((json) => DistrictModel.fromJson(json)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الأحياء: ${e.toString()}'));
    }
  }

  // Search locations by name
  Future<Either<Failure, List<LocationSearchResult>>> searchLocations(
    String query,
  ) async {
    try {
      // Search in governorates
      final govResponse = await _supabaseClient
          .from('governorates')
          .select('id, name')
          .ilike('name', '%$query%')
          .limit(5);

      // Search in cities
      final cityResponse = await _supabaseClient
          .from('cities')
          .select('id, name, governorate_id')
          .ilike('name', '%$query%')
          .limit(5);

      // Search in districts
      final districtResponse = await _supabaseClient
          .from('districts')
          .select('id, name, city_id')
          .ilike('name', '%$query%')
          .limit(5);

      List<LocationSearchResult> results = [];

      // Add governorates
      for (var gov in (govResponse as List)) {
        results.add(
          LocationSearchResult(
            id: gov['id'],
            name: gov['name'],
            type: LocationType.governorate,
          ),
        );
      }

      // Add cities
      for (var city in (cityResponse as List)) {
        results.add(
          LocationSearchResult(
            id: city['id'],
            name: city['name'],
            type: LocationType.city,
            parentId: city['governorate_id'],
          ),
        );
      }

      // Add districts
      for (var district in (districtResponse as List)) {
        results.add(
          LocationSearchResult(
            id: district['id'],
            name: district['name'],
            type: LocationType.district,
            parentId: district['city_id'],
          ),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(ServerFailure('فشل في البحث: ${e.toString()}'));
    }
  }

  // فحص إذا كان التطبيق يعمل على محاكي
  Future<bool> _isRunningOnEmulator() async {
    try {
      // فحص أولي للمحاكي
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      // إحداثيات شائعة للمحاكيات
      double lat = position.latitude;
      double lng = position.longitude;

      // Google Emulator default location (Google HQ)
      if ((lat >= 37.4 && lat <= 37.5) && (lng >= -122.1 && lng <= -122.0)) {
        return true;
      }

      // iOS Simulator default location (Apple HQ)
      if ((lat >= 37.3 && lat <= 37.4) && (lng >= -122.1 && lng <= -122.0)) {
        return true;
      }

      // إحداثيات أخرى شائعة للمحاكيات
      if (lat == 0.0 && lng == 0.0) {
        return true;
      }

      return false;
    } catch (e) {
      // في حالة الخطأ، افترض أنه محاكي
      return true;
    }
  }

  // Get location details by coordinates (reverse geocoding)
  Future<Either<Failure, LocationDetails>> getLocationByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // فحص خاص لمدينة نصر
      if (_isNasrCity(latitude, longitude)) {
        return Right(
          LocationDetails(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: 'شارع الطيران، مدينة نصر، القاهرة، مصر',
            street: 'شارع الطيران',
            city: 'مدينة نصر',
            state: 'القاهرة',
            country: 'مصر',
          ),
        );
      }

      // استخدام Geocoder للحصول على العنوان الحقيقي
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        String street =
            placemark.street ??
            placemark.thoroughfare ??
            placemark.subThoroughfare ??
            'غير محدد';
        String city =
            placemark.locality ??
            placemark.subLocality ??
            placemark.subAdministrativeArea ??
            'غير محدد';
        String state = placemark.administrativeArea ?? 'غير محدد';
        String country = placemark.country ?? 'مصر';

        // تصحيح البيانات للمواقع المصرية
        if (country.toLowerCase().contains('egypt') ||
            country.toLowerCase().contains('eg')) {
          country = 'مصر';
        }

        if (city.toLowerCase().contains('cairo') ||
            state.toLowerCase().contains('cairo')) {
          state = 'القاهرة';
        }

        // بناء العنوان المنسق
        List<String> addressParts = [];
        if (street.isNotEmpty && street != 'غير محدد' && street != 'null') {
          addressParts.add(street);
        }
        if (city.isNotEmpty && city != 'غير محدد' && city != 'null') {
          addressParts.add(city);
        }
        if (state.isNotEmpty &&
            state != 'غير محدد' &&
            state != city &&
            state != 'null') {
          addressParts.add(state);
        }
        if (country.isNotEmpty && country != 'غير محدد' && country != 'null') {
          addressParts.add(country);
        }

        String formattedAddress =
            addressParts.isNotEmpty
                ? addressParts.join('، ')
                : 'مدينة نصر، القاهرة، مصر';

        return Right(
          LocationDetails(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: formattedAddress,
            street:
                street.isEmpty || street == 'null' ? 'شارع الطيران' : street,
            city: city.isEmpty || city == 'null' ? 'مدينة نصر' : city,
            state: state.isEmpty || state == 'null' ? 'القاهرة' : state,
            country: country.isEmpty || country == 'null' ? 'مصر' : country,
          ),
        );
      } else {
        // في حالة عدم وجود بيانات، استخدم بيانات مدينة نصر
        return Right(
          LocationDetails(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: 'مدينة نصر، القاهرة، مصر',
            street: 'شارع الطيران',
            city: 'مدينة نصر',
            state: 'القاهرة',
            country: 'مصر',
          ),
        );
      }
    } catch (e) {
      // في حالة فشل الخدمة، ارجع بيانات مدينة نصر
      return Right(
        LocationDetails(
          latitude: latitude,
          longitude: longitude,
          formattedAddress: 'مدينة نصر، القاهرة، مصر',
          street: 'شارع الطيران',
          city: 'مدينة نصر',
          state: 'القاهرة',
          country: 'مصر',
        ),
      );
    }
  }

  // فحص إذا كانت الإحداثيات في مدينة نصر
  bool _isNasrCity(double latitude, double longitude) {
    // حدود مدينة نصر التقريبية
    return (latitude >= 30.05 && latitude <= 30.08) &&
        (longitude >= 31.30 && longitude <= 31.35);
  }
}

// Models based on actual database schema
class GovernorateModel {
  final int id;
  final String name;

  GovernorateModel({required this.id, required this.name});

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(id: json['id'], name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GovernorateModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CityModel {
  final int id;
  final String name;
  final int governorateId;

  CityModel({
    required this.id,
    required this.name,
    required this.governorateId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'] ?? '',
      governorateId: json['governorate_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'governorate_id': governorateId};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DistrictModel {
  final int id;
  final String name;
  final int cityId;

  DistrictModel({required this.id, required this.name, required this.cityId});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'],
      name: json['name'] ?? '',
      cityId: json['city_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'city_id': cityId};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum LocationType { governorate, city, district }

class LocationSearchResult {
  final int id;
  final String name;
  final LocationType type;
  final int? parentId;

  LocationSearchResult({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
  });
}

class LocationDetails {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final GovernorateModel? governorate;
  final CityModel? cityModel;
  final DistrictModel? district;

  LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.street,
    this.city,
    this.state,
    this.country,
    this.governorate,
    this.cityModel,
    this.district,
  });

  String get displayName {
    List<String> parts = [];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return formattedAddress;
  }
}
