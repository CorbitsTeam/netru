import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phone;
  final String reportType;
  final String reportDetails;
  final double? latitude;
  final double? longitude;
  final DateTime reportDateTime;
  final String? mediaUrl;
  final String? mediaType;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.phone,
    required this.reportType,
    required this.reportDetails,
    this.latitude,
    this.longitude,
    required this.reportDateTime,
    this.mediaUrl,
    this.mediaType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    nationalId,
    phone,
    reportType,
    reportDetails,
    latitude,
    longitude,
    reportDateTime,
    mediaUrl,
    mediaType,
    status,
    createdAt,
    updatedAt,
  ];
}

enum ReportStatus { pending, inProgress, completed, rejected }

extension ReportStatusExtension on ReportStatus {
  String get arabicName {
    switch (this) {
      case ReportStatus.pending:
        return 'في الانتظار';
      case ReportStatus.inProgress:
        return 'قيد المراجعة';
      case ReportStatus.completed:
        return 'مكتمل';
      case ReportStatus.rejected:
        return 'مرفوض';
    }
  }

  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.completed:
        return 'completed';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'completed':
        return ReportStatus.completed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}
