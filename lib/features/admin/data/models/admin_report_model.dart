import '../../domain/entities/admin_report_entity.dart';

class AdminReportModel extends AdminReportEntity {
  const AdminReportModel({
    required super.id,
    super.userId,
    required super.reporterFirstName,
    required super.reporterLastName,
    required super.reporterNationalId,
    required super.reporterPhone,
    super.reportTypeId,
    super.reportTypeCustom,
    required super.reportDetails,
    super.incidentLocationLatitude,
    super.incidentLocationLongitude,
    super.incidentLocationAddress,
    super.incidentDateTime,
    required super.reportStatus,
    required super.priorityLevel,
    super.assignedTo,
    super.assignedToName,
    super.caseNumber,
    required super.submittedAt,
    required super.updatedAt,
    super.resolvedAt,
    super.adminNotes,
    super.publicNotes,
    required super.isAnonymous,
    required super.verificationStatus,
    super.reportTypeName,
    super.media = const [],
    super.comments = const [],
    super.statusHistory = const [],
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    return AdminReportModel(
      id: json['id'],
      userId: json['user_id'],
      reporterFirstName: json['reporter_first_name'],
      reporterLastName: json['reporter_last_name'],
      reporterNationalId: json['reporter_national_id'],
      reporterPhone: json['reporter_phone'],
      reportTypeId: json['report_type_id'],
      reportTypeCustom: json['report_type_custom'],
      reportDetails: json['report_details'],
      incidentLocationLatitude: json['incident_location_latitude']?.toDouble(),
      incidentLocationLongitude:
          json['incident_location_longitude']?.toDouble(),
      incidentLocationAddress: json['incident_location_address'],
      incidentDateTime:
          json['incident_datetime'] != null
              ? DateTime.parse(json['incident_datetime'])
              : null,
      reportStatus: AdminReportStatusExtension.fromString(
        json['report_status'],
      ),
      priorityLevel: PriorityLevelExtension.fromString(json['priority_level']),
      assignedTo: json['assigned_to'],
      assignedToName: json['assigned_to_name'],
      caseNumber: json['case_number'],
      submittedAt: DateTime.parse(json['submitted_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolvedAt:
          json['resolved_at'] != null
              ? DateTime.parse(json['resolved_at'])
              : null,
      adminNotes: json['admin_notes'],
      publicNotes: json['public_notes'],
      isAnonymous: json['is_anonymous'] ?? false,
      verificationStatus: _parseVerificationStatus(json['verification_status']),
      reportTypeName: json['report_type_name'],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((item) => ReportMediaModel.fromJson(item))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((item) => ReportCommentModel.fromJson(item))
              .toList() ??
          [],
      statusHistory:
          (json['status_history'] as List<dynamic>?)
              ?.map((item) => ReportStatusHistoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reporter_first_name': reporterFirstName,
      'reporter_last_name': reporterLastName,
      'reporter_national_id': reporterNationalId,
      'reporter_phone': reporterPhone,
      'report_type_id': reportTypeId,
      'report_type_custom': reportTypeCustom,
      'report_details': reportDetails,
      'incident_location_latitude': incidentLocationLatitude,
      'incident_location_longitude': incidentLocationLongitude,
      'incident_location_address': incidentLocationAddress,
      'incident_datetime': incidentDateTime?.toIso8601String(),
      'report_status': reportStatus.value,
      'priority_level': priorityLevel.value,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'case_number': caseNumber,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'admin_notes': adminNotes,
      'public_notes': publicNotes,
      'is_anonymous': isAnonymous,
      'verification_status': verificationStatus.toString().split('.').last,
      'report_type_name': reportTypeName,
      'media': media.map((m) => (m as ReportMediaModel).toJson()).toList(),
      'comments':
          comments.map((c) => (c as ReportCommentModel).toJson()).toList(),
      'status_history':
          statusHistory
              .map((h) => (h as ReportStatusHistoryModel).toJson())
              .toList(),
    };
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'verified':
        return VerificationStatus.verified;
      case 'flagged':
        return VerificationStatus.flagged;
      default:
        return VerificationStatus.unverified;
    }
  }
}

class ReportMediaModel extends ReportMediaEntity {
  const ReportMediaModel({
    required super.id,
    required super.reportId,
    required super.mediaType,
    required super.fileUrl,
    super.fileName,
    super.fileSize,
    super.mimeType,
    super.description,
    required super.uploadedAt,
    required super.isEvidence,
    super.metadata,
  });

  factory ReportMediaModel.fromJson(Map<String, dynamic> json) {
    return ReportMediaModel(
      id: json['id'],
      reportId: json['report_id'],
      mediaType: _parseMediaType(json['media_type']),
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      description: json['description'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      isEvidence: json['is_evidence'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'media_type': mediaType.toString().split('.').last,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'description': description,
      'uploaded_at': uploadedAt.toIso8601String(),
      'is_evidence': isEvidence,
      'metadata': metadata,
    };
  }

  static MediaType _parseMediaType(String? type) {
    switch (type) {
      case 'video':
        return MediaType.video;
      case 'audio':
        return MediaType.audio;
      case 'document':
        return MediaType.document;
      default:
        return MediaType.image;
    }
  }
}

class ReportCommentModel extends ReportCommentEntity {
  const ReportCommentModel({
    required super.id,
    required super.reportId,
    required super.userId,
    required super.userName,
    required super.commentText,
    required super.isInternal,
    super.parentCommentId,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    super.replies = const [],
  });

  factory ReportCommentModel.fromJson(Map<String, dynamic> json) {
    return ReportCommentModel(
      id: json['id'],
      reportId: json['report_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      commentText: json['comment_text'],
      isInternal: json['is_internal'] ?? false,
      parentCommentId: json['parent_comment_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'] ?? false,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((item) => ReportCommentModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'user_id': userId,
      'user_name': userName,
      'comment_text': commentText,
      'is_internal': isInternal,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'replies':
          replies.map((r) => (r as ReportCommentModel).toJson()).toList(),
    };
  }
}

class ReportStatusHistoryModel extends ReportStatusHistoryEntity {
  const ReportStatusHistoryModel({
    required super.id,
    required super.reportId,
    super.previousStatus,
    required super.newStatus,
    super.changedBy,
    super.changedByName,
    super.changeReason,
    required super.changedAt,
    super.notes,
  });

  factory ReportStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReportStatusHistoryModel(
      id: json['id'],
      reportId: json['report_id'],
      previousStatus:
          json['previous_status'] != null
              ? AdminReportStatusExtension.fromString(json['previous_status'])
              : null,
      newStatus: AdminReportStatusExtension.fromString(json['new_status']),
      changedBy: json['changed_by'],
      changedByName: json['changed_by_name'],
      changeReason: json['change_reason'],
      changedAt: DateTime.parse(json['changed_at']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'previous_status': previousStatus?.value,
      'new_status': newStatus.value,
      'changed_by': changedBy,
      'changed_by_name': changedByName,
      'change_reason': changeReason,
      'changed_at': changedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
