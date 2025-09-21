import 'package:latlong2/latlong.dart';
import '../../domain/entities/heatmap_entity.dart';

class ReportLocationModel extends ReportLocationEntity {
  const ReportLocationModel({
    required super.id,
    required super.location,
    required super.reportType,
    required super.status,
    required super.priority,
    required super.reportDate,
    required super.governorate,
    required super.city,
    required super.address,
  });

  factory ReportLocationModel.fromJson(Map<String, dynamic> json) {
    return ReportLocationModel(
      id: json['id'] ?? '',
      location: LatLng(
        (json['incident_location_latitude'] as num?)?.toDouble() ?? 0.0,
        (json['incident_location_longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      reportType:
          json['report_type_name'] ?? json['report_type_custom'] ?? 'غير محدد',
      status: json['report_status'] ?? 'pending',
      priority: json['priority_level'] ?? 'medium',
      reportDate: DateTime.parse(
        json['submitted_at'] ?? DateTime.now().toIso8601String(),
      ),
      governorate: json['governorate'] ?? 'غير محدد',
      city: json['city'] ?? 'غير محدد',
      address: json['incident_location_address'] ?? 'غير محدد',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_location_latitude': location.latitude,
      'incident_location_longitude': location.longitude,
      'report_type': reportType,
      'report_status': status,
      'priority_level': priority,
      'submitted_at': reportDate.toIso8601String(),
      'governorate': governorate,
      'city': city,
      'incident_location_address': address,
    };
  }
}

class CrimeStatisticsModel extends CrimeStatisticsEntity {
  const CrimeStatisticsModel({
    required super.totalReports,
    required super.pendingReports,
    required super.resolvedReports,
    required super.mostCommonType,
    required super.mostCommonTypePercentage,
    required super.governorateStats,
    required super.reportTypeStats,
  });

  factory CrimeStatisticsModel.fromJson(Map<String, dynamic> json) {
    return CrimeStatisticsModel(
      totalReports: json['total_reports'] ?? 0,
      pendingReports: json['pending_reports'] ?? 0,
      resolvedReports: json['resolved_reports'] ?? 0,
      mostCommonType: json['most_common_type'] ?? 'غير محدد',
      mostCommonTypePercentage:
          (json['most_common_percentage'] as num?)?.toDouble() ?? 0.0,
      governorateStats:
          (json['governorate_stats'] as List<dynamic>?)
              ?.map((e) => GovernorateStatsModel.fromJson(e))
              .toList() ??
          [],
      reportTypeStats:
          (json['report_type_stats'] as List<dynamic>?)
              ?.map((e) => ReportTypeStatsModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GovernorateStatsModel extends GovernorateStatsEntity {
  const GovernorateStatsModel({
    required super.governorateName,
    required super.reportCount,
    required super.centerLocation,
  });

  factory GovernorateStatsModel.fromJson(Map<String, dynamic> json) {
    return GovernorateStatsModel(
      governorateName: json['governorate_name'] ?? '',
      reportCount: json['report_count'] ?? 0,
      centerLocation: LatLng(
        (json['center_lat'] as num?)?.toDouble() ?? 30.0444,
        (json['center_lng'] as num?)?.toDouble() ?? 31.2357,
      ),
    );
  }
}

class ReportTypeStatsModel extends ReportTypeStatsEntity {
  const ReportTypeStatsModel({
    required super.typeName,
    required super.typeNameAr,
    required super.count,
    required super.priority,
  });

  factory ReportTypeStatsModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeStatsModel(
      typeName: json['name'] ?? '',
      typeNameAr: json['name_ar'] ?? '',
      count: json['count'] ?? 0,
      priority: json['priority_level'] ?? 'medium',
    );
  }
}
