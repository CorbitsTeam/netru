import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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

      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation;
    } catch (e) {
      return null;
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
