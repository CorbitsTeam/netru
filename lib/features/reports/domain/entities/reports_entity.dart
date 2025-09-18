import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phone;
  final String reportType;
  final int? reportTypeId; // Added report type ID
  final String reportDetails;
  final double? latitude;
  final double? longitude;
  final String? locationName; // Added location name field
  final DateTime reportDateTime;
  final String? mediaUrl;
  final String? mediaType;
  final ReportStatus status;
  final String? submittedBy; // User ID who submitted the report
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.phone,
    required this.reportType,
    this.reportTypeId,
    required this.reportDetails,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.reportDateTime,
    this.mediaUrl,
    this.mediaType,
    required this.status,
    this.submittedBy,
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
    reportTypeId,
    reportDetails,
    latitude,
    longitude,
    locationName,
    reportDateTime,
    mediaUrl,
    mediaType,
    status,
    submittedBy,
    createdAt,
    updatedAt,
  ];
}

enum ReportStatus {
  received, // تم استلام البلاغ
  underReview, // قيد المراجعة
  dataVerification, // التحقق من البيانات
  actionTaken, // اتخاذ الإجراء المناسب
  completed, // مكتمل
  rejected, // مرفوض
}

extension ReportStatusExtension on ReportStatus {
  String get arabicName {
    switch (this) {
      case ReportStatus.received:
        return 'تم استلام البلاغ';
      case ReportStatus.underReview:
        return 'قيد المراجعة';
      case ReportStatus.dataVerification:
        return 'التحقق من البيانات';
      case ReportStatus.actionTaken:
        return 'اتخاذ الإجراء المناسب';
      case ReportStatus.completed:
        return 'مكتمل';
      case ReportStatus.rejected:
        return 'مرفوض';
    }
  }

  String get description {
    switch (this) {
      case ReportStatus.received:
        return 'تم استلام البلاغ وتسجيله في النظام';
      case ReportStatus.underReview:
        return 'يتم مراجعة البلاغ من قبل الفريق المختص';
      case ReportStatus.dataVerification:
        return 'سيتم التحقق من صحة البيانات المرسلة';
      case ReportStatus.actionTaken:
        return 'سيتم اتخاذ الإجراء المناسب حسب نوع البلاغ';
      case ReportStatus.completed:
        return 'تم إنجاز البلاغ بنجاح';
      case ReportStatus.rejected:
        return 'تم رفض البلاغ';
    }
  }

  String get value {
    switch (this) {
      case ReportStatus.received:
        return 'received';
      case ReportStatus.underReview:
        return 'under_review';
      case ReportStatus.dataVerification:
        return 'data_verification';
      case ReportStatus.actionTaken:
        return 'action_taken';
      case ReportStatus.completed:
        return 'completed';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'received':
        return ReportStatus.received;
      case 'under_review':
        return ReportStatus.underReview;
      case 'data_verification':
        return ReportStatus.dataVerification;
      case 'action_taken':
        return ReportStatus.actionTaken;
      case 'completed':
        return ReportStatus.completed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.received;
    }
  }
}
