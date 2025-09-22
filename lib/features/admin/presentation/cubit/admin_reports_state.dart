import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_report_entity.dart';

abstract class AdminReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminReportsInitial extends AdminReportsState {}

class AdminReportsLoading extends AdminReportsState {}

class AdminReportsLoaded extends AdminReportsState {
  final List<AdminReportEntity> reports;
  final Map<String, int> statistics;
  final bool isRefreshing;

  AdminReportsLoaded({
    required this.reports,
    required this.statistics,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [reports, statistics, isRefreshing];

  AdminReportsLoaded copyWith({
    List<AdminReportEntity>? reports,
    Map<String, int>? statistics,
    bool? isRefreshing,
  }) {
    return AdminReportsLoaded(
      reports: reports ?? this.reports,
      statistics: statistics ?? this.statistics,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class AdminReportsError extends AdminReportsState {
  final String message;

  AdminReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminReportsActionInProgress extends AdminReportsState {
  final String? actionMessage;

  AdminReportsActionInProgress({this.actionMessage});

  @override
  List<Object?> get props => [actionMessage];
}

class AdminReportsActionSuccess extends AdminReportsState {
  final String message;
  final String? actionType;

  AdminReportsActionSuccess(this.message, {this.actionType});

  @override
  List<Object?> get props => [message, actionType];
}

class AdminReportsActionError extends AdminReportsState {
  final String message;
  final String? actionType;

  AdminReportsActionError(this.message, {this.actionType});

  @override
  List<Object?> get props => [message, actionType];
}

// New states for specific admin actions
class AdminReportsAssigning extends AdminReportsState {
  final String reportId;

  AdminReportsAssigning(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class AdminReportsUpdatingStatus extends AdminReportsState {
  final String reportId;
  final AdminReportStatus newStatus;

  AdminReportsUpdatingStatus(this.reportId, this.newStatus);

  @override
  List<Object?> get props => [reportId, newStatus];
}

class AdminReportsVerifying extends AdminReportsState {
  final String reportId;
  final VerificationStatus status;

  AdminReportsVerifying(this.reportId, this.status);

  @override
  List<Object?> get props => [reportId, status];
}

class AdminReportsAddingComment extends AdminReportsState {
  final String reportId;

  AdminReportsAddingComment(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

// State for handling bulk operations
class AdminReportsBulkOperation extends AdminReportsState {
  final String operationType;
  final List<String> reportIds;
  final int processed;
  final int total;

  AdminReportsBulkOperation({
    required this.operationType,
    required this.reportIds,
    required this.processed,
    required this.total,
  });

  @override
  List<Object?> get props => [operationType, reportIds, processed, total];

  double get progress => total > 0 ? processed / total : 0.0;
}

// State for export operations
class AdminReportsExporting extends AdminReportsState {
  final String format;
  final double progress;

  AdminReportsExporting(this.format, this.progress);

  @override
  List<Object?> get props => [format, progress];
}

class AdminReportsExportComplete extends AdminReportsState {
  final String filePath;
  final String format;

  AdminReportsExportComplete(this.filePath, this.format);

  @override
  List<Object?> get props => [filePath, format];
}

// Notification state
class AdminReportsNotificationSent extends AdminReportsState {
  final String message;
  final List<String> userIds;

  AdminReportsNotificationSent(this.message, this.userIds);

  @override
  List<Object?> get props => [message, userIds];
}
