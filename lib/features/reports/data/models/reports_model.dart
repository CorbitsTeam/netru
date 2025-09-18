import '../../domain/entities/reports_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.nationalId,
    required super.phone,
    required super.reportType,
    super.reportTypeId,
    required super.reportDetails,
    super.latitude,
    super.longitude,
    super.locationName,
    required super.reportDateTime,
    super.mediaUrl,
    super.mediaType,
    required super.status,
    super.submittedBy,
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
      reportTypeId: json['report_type_id'] as int?,
      reportDetails: json['report_details'] as String,
      latitude: (json['incident_location_latitude'] as num?)?.toDouble(),
      longitude: (json['incident_location_longitude'] as num?)?.toDouble(),
      locationName: json['incident_location_address'] as String?,
      reportDateTime: DateTime.parse(
        json['incident_datetime'] as String? ?? json['submitted_at'] as String,
      ),
      mediaUrl:
          json['media_url']
              as String?, // This will be handled by join or separate query
      mediaType: json['media_type'] as String?,
      status: mapDatabaseStatusToEnum(json['report_status'] as String),
      submittedBy: json['user_id'] as String?,
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
      'report_type_id': reportTypeId,
      'report_details': reportDetails,
      'incident_location_latitude': latitude,
      'incident_location_longitude': longitude,
      'incident_location_address': locationName,
      'incident_datetime': reportDateTime.toIso8601String(),
      'report_status': mapEnumToDatabaseStatus(status),
      'user_id': submittedBy,
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
      'report_type_id': reportTypeId,
      'report_details': reportDetails,
      'incident_location_latitude': latitude,
      'incident_location_longitude': longitude,
      'incident_location_address': locationName,
      'incident_datetime': reportDateTime.toIso8601String(),
      'report_status': mapEnumToDatabaseStatus(status),
      'user_id': submittedBy,
      'is_anonymous': submittedBy == null, // Anonymous if no user ID
    };
  }

  static ReportStatus mapDatabaseStatusToEnum(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.received;
      case 'under_investigation':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.completed;
      case 'closed':
        return ReportStatus.completed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.received;
    }
  }

  static String mapEnumToDatabaseStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return 'pending';
      case ReportStatus.underReview:
        return 'under_investigation';
      case ReportStatus.dataVerification:
        return 'under_investigation';
      case ReportStatus.actionTaken:
        return 'under_investigation';
      case ReportStatus.completed:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }
}
