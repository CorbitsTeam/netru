import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/usecases/manage_reports.dart';
import '../../../../core/services/simple_notification_service.dart';
import 'admin_reports_state.dart';

class AdminReportsCubit extends Cubit<AdminReportsState> {
  final GetAllReports getAllReports;
  final GetReportById getReportById;
  final UpdateReportStatus updateReportStatus;
  final AssignReport assignReport;
  final VerifyReport verifyReport;
  final AddReportComment addReportComment;
  final SimpleNotificationService notificationService;

  AdminReportsCubit({
    required this.getAllReports,
    required this.getReportById,
    required this.updateReportStatus,
    required this.assignReport,
    required this.verifyReport,
    required this.addReportComment,
    required this.notificationService,
  }) : super(AdminReportsInitial());

  Future<void> loadReports({
    AdminReportStatus? status,
    String? governorate,
    String? searchQuery,
    PriorityLevel? priority,
    VerificationStatus? verificationStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    emit(AdminReportsLoading());

    final params = GetReportsParams(
      page: page,
      limit: limit,
      status: status,
      priority: priority,
      verificationStatus: verificationStatus,
      assignedTo: assignedTo,
      governorate: governorate,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
    );

    final result = await getAllReports(params);

    result.fold(
      (failure) {
        emit(
          AdminReportsError('حدث خطأ في تحميل البلاغات: ${failure.toString()}'),
        );
      },
      (reports) {
        final statistics = _calculateStatistics(reports);
        emit(AdminReportsLoaded(reports: reports, statistics: statistics));
      },
    );
  }

  Future<void> updateReportStatusById(
    String reportId,
    AdminReportStatus newStatus, {
    String? notes,
  }) async {
    emit(AdminReportsActionInProgress());

    final params = UpdateReportStatusParams(
      reportId: reportId,
      status: newStatus,
      notes: notes,
    );

    final result = await updateReportStatus(params);

    result.fold(
      (failure) {
        emit(
          AdminReportsActionError(
            'فشل في تحديث حالة البلاغ: ${failure.toString()}',
          ),
        );
      },
      (updatedReport) {
        emit(AdminReportsActionSuccess('تم تحديث حالة البلاغ بنجاح'));

        // إرسال إشعار نجاح للمسؤول
        notificationService.sendSuccessNotification(
          message: 'تم تحديث البلاغ #${updatedReport.caseNumber} بنجاح',
        );

        // تحديث البلاغ المحدد في القائمة بدلاً من إعادة تحميل كل البيانات
        _updateReportInList(updatedReport);
      },
    );
  }

  Future<void> assignReportToInvestigator(
    String reportId,
    String investigatorId, {
    String? notes,
  }) async {
    emit(AdminReportsActionInProgress());

    final params = AssignReportParams(
      reportId: reportId,
      assignedTo: investigatorId,
      assignmentNotes: notes,
    );

    final result = await assignReport(params);

    result.fold(
      (failure) {
        emit(
          AdminReportsActionError('فشل في تعيين المحقق: ${failure.toString()}'),
        );
      },
      (success) {
        emit(AdminReportsActionSuccess('تم تعيين المحقق بنجاح'));

        // إرسال إشعار نجاح للمسؤول
        notificationService.sendSuccessNotification(
          message: 'تم تعيين المحقق للبلاغ بنجاح',
        );

        // تحديث سريع للقائمة - سيتم تحديث البلاغ عندما يتم جلبه مرة أخرى
        loadReports();
      },
    );
  }

  Future<void> verifyReportById(
    String reportId,
    VerificationStatus status, {
    String? notes,
  }) async {
    emit(AdminReportsActionInProgress());

    final params = VerifyReportParams(
      reportId: reportId,
      status: status,
      notes: notes,
    );

    final result = await verifyReport(params);

    result.fold(
      (failure) {
        emit(
          AdminReportsActionError(
            'فشل في التحقق من البلاغ: ${failure.toString()}',
          ),
        );
      },
      (success) {
        emit(AdminReportsActionSuccess('تم التحقق من البلاغ بنجاح'));
        loadReports(); // إعادة تحميل البيانات للحصول على آخر التحديثات
      },
    );
  }

  Future<void> approveReport(String reportId, {String? notes}) async {
    await updateReportStatusById(
      reportId,
      AdminReportStatus.resolved,
      notes: notes,
    );
  }

  Future<void> rejectReport(String reportId, {String? notes}) async {
    await updateReportStatusById(
      reportId,
      AdminReportStatus.rejected,
      notes: notes,
    );
  }

  Future<void> addComment(
    String reportId,
    String commentText, {
    bool isInternal = true,
  }) async {
    emit(AdminReportsActionInProgress());

    final params = AddCommentParams(
      reportId: reportId,
      commentText: commentText,
      isInternal: isInternal,
    );

    final result = await addReportComment(params);

    result.fold(
      (failure) {
        emit(
          AdminReportsActionError(
            'فشل في إضافة التعليق: ${failure.toString()}',
          ),
        );
      },
      (comment) {
        emit(AdminReportsActionSuccess('تم إضافة التعليق بنجاح'));
        loadReports(); // إعادة تحميل البيانات
      },
    );
  }

  Map<String, int> _calculateStatistics(List<AdminReportEntity> reports) {
    return {
      'total': reports.length,
      'pending':
          reports
              .where((r) => r.reportStatus == AdminReportStatus.pending)
              .length,
      'underInvestigation':
          reports
              .where(
                (r) => r.reportStatus == AdminReportStatus.underInvestigation,
              )
              .length,
      'resolved':
          reports
              .where((r) => r.reportStatus == AdminReportStatus.resolved)
              .length,
      'rejected':
          reports
              .where((r) => r.reportStatus == AdminReportStatus.rejected)
              .length,
      'closed':
          reports
              .where((r) => r.reportStatus == AdminReportStatus.closed)
              .length,
      'received':
          reports
              .where((r) => r.reportStatus == AdminReportStatus.received)
              .length,
      'highPriority':
          reports
              .where(
                (r) =>
                    r.priorityLevel == PriorityLevel.high ||
                    r.priorityLevel == PriorityLevel.urgent,
              )
              .length,
      'unverified':
          reports
              .where(
                (r) => r.verificationStatus == VerificationStatus.unverified,
              )
              .length,
      'verified':
          reports
              .where((r) => r.verificationStatus == VerificationStatus.verified)
              .length,
      'flagged':
          reports
              .where((r) => r.verificationStatus == VerificationStatus.flagged)
              .length,
    };
  }

  // Filter methods
  List<AdminReportEntity> getReportsByStatus(AdminReportStatus status) {
    if (state is AdminReportsLoaded) {
      return (state as AdminReportsLoaded).reports
          .where((report) => report.reportStatus == status)
          .toList();
    }
    return [];
  }

  List<AdminReportEntity> getReportsByPriority(PriorityLevel priority) {
    if (state is AdminReportsLoaded) {
      return (state as AdminReportsLoaded).reports
          .where((report) => report.priorityLevel == priority)
          .toList();
    }
    return [];
  }

  List<AdminReportEntity> getUnassignedReports() {
    if (state is AdminReportsLoaded) {
      return (state as AdminReportsLoaded).reports
          .where(
            (report) => report.assignedTo == null || report.assignedTo!.isEmpty,
          )
          .toList();
    }
    return [];
  }

  void clearActionState() {
    if (state is AdminReportsActionInProgress ||
        state is AdminReportsActionSuccess ||
        state is AdminReportsActionError) {
      loadReports();
    }
  }

  /// تحديث بلاغ محدد في القائمة دون إعادة تحميل كامل
  void _updateReportInList(AdminReportEntity updatedReport) {
    if (state is AdminReportsLoaded) {
      final currentState = state as AdminReportsLoaded;
      final updatedReports =
          currentState.reports.map((report) {
            if (report.id == updatedReport.id) {
              return updatedReport;
            }
            return report;
          }).toList();

      final updatedStatistics = _calculateStatistics(updatedReports);
      emit(
        AdminReportsLoaded(
          reports: updatedReports,
          statistics: updatedStatistics,
        ),
      );
    }
  }
}
