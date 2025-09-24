import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/cases/presentation/cubit/cases_cubit.dart';
import 'package:netru_app/features/cases/presentation/cubit/cases_state.dart';
import 'package:netru_app/features/cases/data/models/case_model.dart';
import 'package:netru_app/core/services/logger_service.dart';

import '../../../../core/theme/app_colors.dart';

class TrendingCasesCard extends StatefulWidget {
  const TrendingCasesCard({super.key});

  @override
  State<TrendingCasesCard> createState() => _TrendingCasesCardState();
}

class _TrendingCasesCardState extends State<TrendingCasesCard> {
  @override
  void initState() {
    super.initState();
    // تحميل القضايا الرائجة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDependencyRegistered<CasesCubit>()) {
        try {
          context.read<CasesCubit>().loadTrendingCases(limit: 3);
        } catch (_) {}
      } else {
        sl.get<LoggerService>().logInfo(
          '⚠️ CasesCubit غير مسجل في GetIt — قد تحتاج لإعادة تشغيل التطبيق (full restart) بعد تغييرات DI.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDependencyRegistered<CasesCubit>()) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.yellow[50],
          border: Border.all(color: Colors.yellow.withValues(alpha: 0.6)),
        ),
        child: const Center(
          child: Text('تبعيات القضايا غير جاهزة — قم بعمل Restart للتطبيق.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => sl<CasesCubit>(),
      child: BlocBuilder<CasesCubit, CasesState>(
        builder: (context, state) {
          if (state is CasesLoading) {
            return _buildLoadingCard();
          }

          if (state is CasesError) {
            return _buildErrorCard(state.message);
          }

          if (state is TrendingCasesLoaded) {
            if (state.cases.isEmpty) {
              return _buildEmptyCard();
            }

            return _buildTrendingCasesList(state.cases);
          }

          return _buildEmptyCard();
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[100],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل القضايا الرائجة',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[700]),
            ),
            SizedBox(height: 4.h),
            Text(
              message.length > 50 ? '${message.substring(0, 50)}...' : message,
              style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'لا توجد قضايا رائجة',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCasesList(List<CaseModel> cases) {
    return Column(
      children:
          cases.map((caseModel) => _buildTrendingCaseCard(caseModel)).toList(),
    );
  }

  Widget _buildTrendingCaseCard(CaseModel caseModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trending badge and priority
          Row(
            children: [
              // Trending badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'رائج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Priority badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getPriorityColor(caseModel.priority),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  caseModel.priorityText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Date
              Text(
                _formatDate(caseModel.incidentDate),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            caseModel.displayTitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            caseModel.displayDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),

          // Footer with location and status
          Row(
            children: [
              // Location
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        caseModel.displayLocation,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    caseModel.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: _getStatusColor(
                      caseModel.status,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  caseModel.statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: _getStatusColor(caseModel.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_investigation':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
