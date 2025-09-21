import 'package:latlong2/latlong.dart';

class ReportLocationEntity {
  final String id;
  final LatLng location;
  final String reportType;
  final String status;
  final String priority;
  final DateTime reportDate;
  final String governorate;
  final String city;
  final String address;

  const ReportLocationEntity({
    required this.id,
    required this.location,
    required this.reportType,
    required this.status,
    required this.priority,
    required this.reportDate,
    required this.governorate,
    required this.city,
    required this.address,
  });
}

class CrimeStatisticsEntity {
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final String mostCommonType;
  final double mostCommonTypePercentage;
  final List<GovernorateStatsEntity> governorateStats;
  final List<ReportTypeStatsEntity> reportTypeStats;

  const CrimeStatisticsEntity({
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.mostCommonType,
    required this.mostCommonTypePercentage,
    required this.governorateStats,
    required this.reportTypeStats,
  });
}

class GovernorateStatsEntity {
  final String governorateName;
  final int reportCount;
  final LatLng centerLocation;

  const GovernorateStatsEntity({
    required this.governorateName,
    required this.reportCount,
    required this.centerLocation,
  });
}

class ReportTypeStatsEntity {
  final String typeName;
  final String typeNameAr;
  final int count;
  final String priority;

  const ReportTypeStatsEntity({
    required this.typeName,
    required this.typeNameAr,
    required this.count,
    required this.priority,
  });
}
