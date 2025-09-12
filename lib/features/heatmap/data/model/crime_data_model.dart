import 'package:latlong2/latlong.dart';

class CrimeDataModel {
  final LatLng location;
  final int crimeCount;
  final String area;
  final String description;
  final DateTime? lastIncident;
  final List<String>? crimeTypes;

  CrimeDataModel({
    required this.location,
    required this.crimeCount,
    required this.area,
    required this.description,
    this.lastIncident,
    this.crimeTypes,
  });

  /// تحديد مستوى الخطر بناءً على عدد الجرائم
  CrimeLevel get crimeLevel {
    if (crimeCount >= 30) return CrimeLevel.high;
    if (crimeCount >= 15) {
      return CrimeLevel.medium;
    }
    return CrimeLevel.low;
  }

  /// تحويل البيانات من JSON
  factory CrimeDataModel.fromJson(
      Map<String, dynamic> json) {
    return CrimeDataModel(
      location: LatLng(
        json['latitude']?.toDouble() ?? 0.0,
        json['longitude']?.toDouble() ?? 0.0,
      ),
      crimeCount: json['crimeCount'] ?? 0,
      area: json['area'] ?? '',
      description: json['description'] ?? '',
      lastIncident: json['lastIncident'] != null
          ? DateTime.parse(json['lastIncident'])
          : null,
      crimeTypes: json['crimeTypes'] != null
          ? List<String>.from(json['crimeTypes'])
          : null,
    );
  }

  /// تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'crimeCount': crimeCount,
      'area': area,
      'description': description,
      'lastIncident':
          lastIncident?.toIso8601String(),
      'crimeTypes': crimeTypes,
    };
  }

  @override
  String toString() {
    return 'CrimeDataModel(location: $location, crimeCount: $crimeCount, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrimeDataModel &&
        other.location == location &&
        other.crimeCount == crimeCount &&
        other.area == area;
  }

  @override
  int get hashCode {
    return location.hashCode ^
        crimeCount.hashCode ^
        area.hashCode;
  }
}

/// مستويات الخطر
enum CrimeLevel {
  low, // آمن (أخضر)
  medium, // متوسط (برتقالي)
  high, // خطير (أحمر)
}

extension CrimeLevelExtension on CrimeLevel {
  String get displayName {
    switch (this) {
      case CrimeLevel.low:
        return 'منطقة آمنة';
      case CrimeLevel.medium:
        return 'متوسطة الخطورة';
      case CrimeLevel.high:
        return 'منطقة خطيرة';
    }
  }

  String get color {
    switch (this) {
      case CrimeLevel.low:
        return '#4CAF50'; // أخضر
      case CrimeLevel.medium:
        return '#FF9800'; // برتقالي
      case CrimeLevel.high:
        return '#F44336'; // أحمر
    }
  }
}
