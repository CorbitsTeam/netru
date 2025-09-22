import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final ReportStatus status;
  final ReportPriority priority;
  final String? categoryName;
  final String? governorate;
  final String? city;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedToName;
  final int mediaCount;
  final int commentsCount;

  const ReportSummaryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.categoryName,
    this.governorate,
    this.city,
    required this.createdAt,
    required this.updatedAt,
    this.assignedToName,
    this.mediaCount = 0,
    this.commentsCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    categoryName,
    governorate,
    city,
    createdAt,
    updatedAt,
    assignedToName,
    mediaCount,
    commentsCount,
  ];
}

enum ReportStatus {
  pending,
  underReview,
  inProgress,
  resolved,
  rejected,
  closed,
}

enum ReportPriority { low, medium, high, urgent }

extension ReportStatusExtension on ReportStatus {
  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.underReview:
        return 'under_review';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
      case ReportStatus.closed:
        return 'closed';
    }
  }

  String get arabicName {
    switch (this) {
      case ReportStatus.pending:
        return 'في الانتظار';
      case ReportStatus.underReview:
        return 'قيد المراجعة';
      case ReportStatus.inProgress:
        return 'قيد التنفيذ';
      case ReportStatus.resolved:
        return 'تم الحل';
      case ReportStatus.rejected:
        return 'مرفوض';
      case ReportStatus.closed:
        return 'مغلق';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_review':
        return ReportStatus.underReview;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case 'closed':
        return ReportStatus.closed;
      default:
        return ReportStatus.pending;
    }
  }
}

extension ReportPriorityExtension on ReportPriority {
  String get value {
    switch (this) {
      case ReportPriority.low:
        return 'low';
      case ReportPriority.medium:
        return 'medium';
      case ReportPriority.high:
        return 'high';
      case ReportPriority.urgent:
        return 'urgent';
    }
  }

  String get arabicName {
    switch (this) {
      case ReportPriority.low:
        return 'منخفضة';
      case ReportPriority.medium:
        return 'متوسطة';
      case ReportPriority.high:
        return 'عالية';
      case ReportPriority.urgent:
        return 'عاجلة';
    }
  }

  static ReportPriority fromString(String value) {
    switch (value) {
      case 'low':
        return ReportPriority.low;
      case 'medium':
        return ReportPriority.medium;
      case 'high':
        return ReportPriority.high;
      case 'urgent':
        return ReportPriority.urgent;
      default:
        return ReportPriority.medium;
    }
  }
}
