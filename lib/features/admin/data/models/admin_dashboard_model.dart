import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalReports,
    required super.pendingReports,
    required super.underInvestigationReports,
    required super.resolvedReports,
    required super.rejectedReports,
    required super.totalUsers,
    required super.citizenUsers,
    required super.foreignerUsers,
    required super.adminUsers,
    required super.pendingVerifications,
    required super.totalNewsArticles,
    required super.publishedNewsArticles,
    required super.reportsByGovernorate,
    required super.reportsByType,
    required super.reportsByStatus,
    required super.reportTrends,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalReports: json['total_reports'] ?? 0,
      pendingReports: json['pending_reports'] ?? 0,
      underInvestigationReports: json['under_investigation_reports'] ?? 0,
      resolvedReports: json['resolved_reports'] ?? 0,
      rejectedReports: json['rejected_reports'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      citizenUsers: json['citizen_users'] ?? 0,
      foreignerUsers: json['foreigner_users'] ?? 0,
      adminUsers: json['admin_users'] ?? 0,
      pendingVerifications: json['pending_verifications'] ?? 0,
      totalNewsArticles: json['total_news_articles'] ?? 0,
      publishedNewsArticles: json['published_news_articles'] ?? 0,
      reportsByGovernorate: Map<String, int>.from(
        json['reports_by_governorate'] ?? {},
      ),
      reportsByType: Map<String, int>.from(json['reports_by_type'] ?? {}),
      reportsByStatus: Map<String, int>.from(json['reports_by_status'] ?? {}),
      reportTrends:
          (json['report_trends'] as List<dynamic>?)
              ?.map((item) => ReportTrendDataModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reports': totalReports,
      'pending_reports': pendingReports,
      'under_investigation_reports': underInvestigationReports,
      'resolved_reports': resolvedReports,
      'rejected_reports': rejectedReports,
      'total_users': totalUsers,
      'citizen_users': citizenUsers,
      'foreigner_users': foreignerUsers,
      'admin_users': adminUsers,
      'pending_verifications': pendingVerifications,
      'total_news_articles': totalNewsArticles,
      'published_news_articles': publishedNewsArticles,
      'reports_by_governorate': reportsByGovernorate,
      'reports_by_type': reportsByType,
      'reports_by_status': reportsByStatus,
      'report_trends':
          reportTrends
              .map((trend) => (trend as ReportTrendDataModel).toJson())
              .toList(),
    };
  }
}

class ReportTrendDataModel extends ReportTrendData {
  const ReportTrendDataModel({
    required super.date,
    required super.count,
    required super.status,
  });

  factory ReportTrendDataModel.fromJson(Map<String, dynamic> json) {
    return ReportTrendDataModel(
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'count': count, 'status': status};
  }
}
