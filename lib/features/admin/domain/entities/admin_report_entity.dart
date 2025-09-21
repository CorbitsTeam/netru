import 'package:equatable/equatable.dart';

class AdminReportEntity extends Equatable {
  final String id;
  final String? userId;
  final String reporterFirstName;
  final String reporterLastName;
  final String reporterNationalId;
  final String reporterPhone;
  final int? reportTypeId;
  final String? reportTypeCustom;
  final String reportDetails;
  final double? incidentLocationLatitude;
  final double? incidentLocationLongitude;
  final String? incidentLocationAddress;
  final DateTime? incidentDateTime;
  final AdminReportStatus reportStatus;
  final PriorityLevel priorityLevel;
  final String? assignedTo;
  final String? assignedToName;
  final String? caseNumber;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? adminNotes;
  final String? publicNotes;
  final bool isAnonymous;
  final VerificationStatus verificationStatus;
  final String? reportTypeName;
  final List<ReportMediaEntity> media;
  final List<ReportCommentEntity> comments;
  final List<ReportStatusHistoryEntity> statusHistory;

  const AdminReportEntity({
    required this.id,
    this.userId,
    required this.reporterFirstName,
    required this.reporterLastName,
    required this.reporterNationalId,
    required this.reporterPhone,
    this.reportTypeId,
    this.reportTypeCustom,
    required this.reportDetails,
    this.incidentLocationLatitude,
    this.incidentLocationLongitude,
    this.incidentLocationAddress,
    this.incidentDateTime,
    required this.reportStatus,
    required this.priorityLevel,
    this.assignedTo,
    this.assignedToName,
    this.caseNumber,
    required this.submittedAt,
    required this.updatedAt,
    this.resolvedAt,
    this.adminNotes,
    this.publicNotes,
    required this.isAnonymous,
    required this.verificationStatus,
    this.reportTypeName,
    this.media = const [],
    this.comments = const [],
    this.statusHistory = const [],
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    reporterFirstName,
    reporterLastName,
    reporterNationalId,
    reporterPhone,
    reportTypeId,
    reportTypeCustom,
    reportDetails,
    incidentLocationLatitude,
    incidentLocationLongitude,
    incidentLocationAddress,
    incidentDateTime,
    reportStatus,
    priorityLevel,
    assignedTo,
    assignedToName,
    caseNumber,
    submittedAt,
    updatedAt,
    resolvedAt,
    adminNotes,
    publicNotes,
    isAnonymous,
    verificationStatus,
    reportTypeName,
    media,
    comments,
    statusHistory,
  ];

  AdminReportEntity copyWith({
    String? id,
    String? userId,
    String? reporterFirstName,
    String? reporterLastName,
    String? reporterNationalId,
    String? reporterPhone,
    int? reportTypeId,
    String? reportTypeCustom,
    String? reportDetails,
    double? incidentLocationLatitude,
    double? incidentLocationLongitude,
    String? incidentLocationAddress,
    DateTime? incidentDateTime,
    AdminReportStatus? reportStatus,
    PriorityLevel? priorityLevel,
    String? assignedTo,
    String? assignedToName,
    String? caseNumber,
    DateTime? submittedAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? adminNotes,
    String? publicNotes,
    bool? isAnonymous,
    VerificationStatus? verificationStatus,
    String? reportTypeName,
    List<ReportMediaEntity>? media,
    List<ReportCommentEntity>? comments,
    List<ReportStatusHistoryEntity>? statusHistory,
  }) {
    return AdminReportEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reporterFirstName: reporterFirstName ?? this.reporterFirstName,
      reporterLastName: reporterLastName ?? this.reporterLastName,
      reporterNationalId: reporterNationalId ?? this.reporterNationalId,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      reportTypeId: reportTypeId ?? this.reportTypeId,
      reportTypeCustom: reportTypeCustom ?? this.reportTypeCustom,
      reportDetails: reportDetails ?? this.reportDetails,
      incidentLocationLatitude:
          incidentLocationLatitude ?? this.incidentLocationLatitude,
      incidentLocationLongitude:
          incidentLocationLongitude ?? this.incidentLocationLongitude,
      incidentLocationAddress:
          incidentLocationAddress ?? this.incidentLocationAddress,
      incidentDateTime: incidentDateTime ?? this.incidentDateTime,
      reportStatus: reportStatus ?? this.reportStatus,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      caseNumber: caseNumber ?? this.caseNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      publicNotes: publicNotes ?? this.publicNotes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      reportTypeName: reportTypeName ?? this.reportTypeName,
      media: media ?? this.media,
      comments: comments ?? this.comments,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

class ReportMediaEntity extends Equatable {
  final String id;
  final String reportId;
  final MediaType mediaType;
  final String fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? description;
  final DateTime uploadedAt;
  final bool isEvidence;
  final Map<String, dynamic>? metadata;

  const ReportMediaEntity({
    required this.id,
    required this.reportId,
    required this.mediaType,
    required this.fileUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.description,
    required this.uploadedAt,
    required this.isEvidence,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    reportId,
    mediaType,
    fileUrl,
    fileName,
    fileSize,
    mimeType,
    description,
    uploadedAt,
    isEvidence,
    metadata,
  ];
}

class ReportCommentEntity extends Equatable {
  final String id;
  final String reportId;
  final String userId;
  final String userName;
  final String commentText;
  final bool isInternal;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<ReportCommentEntity> replies;

  const ReportCommentEntity({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.isInternal,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.replies = const [],
  });

  @override
  List<Object?> get props => [
    id,
    reportId,
    userId,
    userName,
    commentText,
    isInternal,
    parentCommentId,
    createdAt,
    updatedAt,
    isDeleted,
    replies,
  ];
}

class ReportStatusHistoryEntity extends Equatable {
  final String id;
  final String reportId;
  final AdminReportStatus? previousStatus;
  final AdminReportStatus newStatus;
  final String? changedBy;
  final String? changedByName;
  final String? changeReason;
  final DateTime changedAt;
  final String? notes;

  const ReportStatusHistoryEntity({
    required this.id,
    required this.reportId,
    this.previousStatus,
    required this.newStatus,
    this.changedBy,
    this.changedByName,
    this.changeReason,
    required this.changedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    reportId,
    previousStatus,
    newStatus,
    changedBy,
    changedByName,
    changeReason,
    changedAt,
    notes,
  ];
}

enum AdminReportStatus {
  pending,
  underInvestigation,
  resolved,
  closed,
  rejected,
  received,
}

enum PriorityLevel { low, medium, high, urgent }

enum MediaType { image, video, audio, document }

enum VerificationStatus { unverified, verified, flagged }

extension AdminReportStatusExtension on AdminReportStatus {
  String get value {
    switch (this) {
      case AdminReportStatus.pending:
        return 'pending';
      case AdminReportStatus.underInvestigation:
        return 'under_investigation';
      case AdminReportStatus.resolved:
        return 'resolved';
      case AdminReportStatus.closed:
        return 'closed';
      case AdminReportStatus.rejected:
        return 'rejected';
      case AdminReportStatus.received:
        return 'received';
    }
  }

  String get arabicName {
    switch (this) {
      case AdminReportStatus.pending:
        return 'في الانتظار';
      case AdminReportStatus.underInvestigation:
        return 'قيد التحقيق';
      case AdminReportStatus.resolved:
        return 'تم الحل';
      case AdminReportStatus.closed:
        return 'مغلق';
      case AdminReportStatus.rejected:
        return 'مرفوض';
      case AdminReportStatus.received:
        return 'تم الاستلام';
    }
  }

  static AdminReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return AdminReportStatus.pending;
      case 'under_investigation':
        return AdminReportStatus.underInvestigation;
      case 'resolved':
        return AdminReportStatus.resolved;
      case 'closed':
        return AdminReportStatus.closed;
      case 'rejected':
        return AdminReportStatus.rejected;
      case 'received':
        return AdminReportStatus.received;
      default:
        return AdminReportStatus.pending;
    }
  }
}

extension PriorityLevelExtension on PriorityLevel {
  String get value {
    switch (this) {
      case PriorityLevel.low:
        return 'low';
      case PriorityLevel.medium:
        return 'medium';
      case PriorityLevel.high:
        return 'high';
      case PriorityLevel.urgent:
        return 'urgent';
    }
  }

  String get arabicName {
    switch (this) {
      case PriorityLevel.low:
        return 'منخفض';
      case PriorityLevel.medium:
        return 'متوسط';
      case PriorityLevel.high:
        return 'عالي';
      case PriorityLevel.urgent:
        return 'عاجل';
    }
  }

  static PriorityLevel fromString(String value) {
    switch (value) {
      case 'low':
        return PriorityLevel.low;
      case 'medium':
        return PriorityLevel.medium;
      case 'high':
        return PriorityLevel.high;
      case 'urgent':
        return PriorityLevel.urgent;
      default:
        return PriorityLevel.medium;
    }
  }
}
