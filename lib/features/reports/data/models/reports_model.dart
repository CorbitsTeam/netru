import '../../domain/entities/reports_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.nationalId,
    required super.phone,
    required super.reportType,
    required super.reportDetails,
    super.latitude,
    super.longitude,
    required super.reportDateTime,
    super.mediaUrl,
    super.mediaType,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      firstName: json['reporter_first_name'] as String,
      lastName: json['reporter_last_name'] as String,
      nationalId: json['reporter_national_id'] as String,
      phone: json['reporter_phone'] as String,
      reportType: json['report_type_custom'] as String? ?? 'بلاغ آخر',
      reportDetails: json['report_details'] as String,
      latitude: (json['incident_location_latitude'] as num?)?.toDouble(),
      longitude: (json['incident_location_longitude'] as num?)?.toDouble(),
      reportDateTime: DateTime.parse(
        json['incident_datetime'] as String? ?? json['submitted_at'] as String,
      ),
      mediaUrl:
          json['media_url']
              as String?, // This will be handled by join or separate query
      mediaType: json['media_type'] as String?,
      status: mapDatabaseStatusToEnum(json['report_status'] as String),
      createdAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_first_name': firstName,
      'reporter_last_name': lastName,
      'reporter_national_id': nationalId,
      'reporter_phone': phone,
      'report_type_custom': reportType,
      'report_details': reportDetails,
      'incident_location_latitude': latitude,
      'incident_location_longitude': longitude,
      'incident_datetime': reportDateTime.toIso8601String(),
      'report_status': mapEnumToDatabaseStatus(status),
      'submitted_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'reporter_first_name': firstName,
      'reporter_last_name': lastName,
      'reporter_national_id': nationalId,
      'reporter_phone': phone,
      'report_type_custom': reportType,
      'report_details': reportDetails,
      'incident_location_latitude': latitude,
      'incident_location_longitude': longitude,
      'incident_datetime': reportDateTime.toIso8601String(),
      'report_status': mapEnumToDatabaseStatus(status),
      'is_anonymous': true, // Since we're not requiring user login
    };
  }

  static ReportStatus mapDatabaseStatusToEnum(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_investigation':
        return ReportStatus.inProgress;
      case 'resolved':
      case 'closed':
        return ReportStatus.completed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  static String mapEnumToDatabaseStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inProgress:
        return 'under_investigation';
      case ReportStatus.completed:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }
}
