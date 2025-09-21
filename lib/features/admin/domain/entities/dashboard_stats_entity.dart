import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int totalReports;
  final int pendingReports;
  final int underInvestigationReports;
  final int resolvedReports;
  final int rejectedReports;
  final int totalUsers;
  final int citizenUsers;
  final int foreignerUsers;
  final int adminUsers;
  final int pendingVerifications;
  final int totalNewsArticles;
  final int publishedNewsArticles;
  final Map<String, int> reportsByGovernorate;
  final Map<String, int> reportsByType;
  final Map<String, int> reportsByStatus;
  final List<ReportTrendData> reportTrends;

  const DashboardStatsEntity({
    required this.totalReports,
    required this.pendingReports,
    required this.underInvestigationReports,
    required this.resolvedReports,
    required this.rejectedReports,
    required this.totalUsers,
    required this.citizenUsers,
    required this.foreignerUsers,
    required this.adminUsers,
    required this.pendingVerifications,
    required this.totalNewsArticles,
    required this.publishedNewsArticles,
    required this.reportsByGovernorate,
    required this.reportsByType,
    required this.reportsByStatus,
    required this.reportTrends,
  });

  @override
  List<Object?> get props => [
    totalReports,
    pendingReports,
    underInvestigationReports,
    resolvedReports,
    rejectedReports,
    totalUsers,
    citizenUsers,
    foreignerUsers,
    adminUsers,
    pendingVerifications,
    totalNewsArticles,
    publishedNewsArticles,
    reportsByGovernorate,
    reportsByType,
    reportsByStatus,
    reportTrends,
  ];
}

class ReportTrendData extends Equatable {
  final DateTime date;
  final int count;
  final String status;

  const ReportTrendData({
    required this.date,
    required this.count,
    required this.status,
  });

  @override
  List<Object?> get props => [date, count, status];
}
