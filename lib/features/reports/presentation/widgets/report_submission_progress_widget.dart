import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ReportSubmissionProgressWidget extends StatelessWidget {
  final double progress; // من 0.0 إلى 1.0
  final String currentStep;
  final bool isUploading;
  final int? uploadedFiles;
  final int? totalFiles;
  final String? errorMessage;

  const ReportSubmissionProgressWidget({
    super.key,
    required this.progress,
    required this.currentStep,
    this.isUploading = false,
    this.uploadedFiles,
    this.totalFiles,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              errorMessage != null
                  ? Colors.red.withOpacity(0.3)
                  : AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          _buildProgressBar(),
          SizedBox(height: 12.h),
          _buildProgressInfo(),
          if (isUploading && uploadedFiles != null && totalFiles != null) ...[
            SizedBox(height: 12.h),
            _buildFileUploadProgress(),
          ],
          if (errorMessage != null) ...[
            SizedBox(height: 12.h),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getHeaderTitle(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (currentStep.isNotEmpty)
                Text(
                  currentStep,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        if (isUploading)
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم العام',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: progress * constraints.maxWidth,
                  height: 8.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          errorMessage != null
                              ? [Colors.red, Colors.red.shade400]
                              : [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(0.8),
                              ],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressInfo() {
    return Row(
      children: [
        Expanded(child: _buildStepIndicator('البيانات', progress >= 0.2)),
        SizedBox(width: 8.w),
        Expanded(child: _buildStepIndicator('الملفات', progress >= 0.6)),
        SizedBox(width: 8.w),
        Expanded(child: _buildStepIndicator('الإرسال', progress >= 0.8)),
        SizedBox(width: 8.w),
        Expanded(child: _buildStepIndicator('مكتمل', progress >= 1.0)),
      ],
    );
  }

  Widget _buildStepIndicator(String label, bool isCompleted) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              isCompleted
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12.sp,
            color: isCompleted ? AppColors.primaryColor : Colors.grey[400],
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: isCompleted ? AppColors.primaryColor : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadProgress() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_upload, color: Colors.blue[600], size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رفع الملفات',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                Text(
                  'تم رفع $uploadedFiles من $totalFiles ملف',
                  style: TextStyle(fontSize: 10.sp, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
          Text(
            '${((uploadedFiles! / totalFiles!) * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 10.sp, color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (errorMessage != null) return Colors.red;
    if (progress >= 1.0) return Colors.green;
    if (isUploading) return Colors.blue;
    return AppColors.primaryColor;
  }

  IconData _getStatusIcon() {
    if (errorMessage != null) return Icons.error;
    if (progress >= 1.0) return Icons.check_circle;
    if (isUploading) return Icons.cloud_upload;
    return Icons.assignment;
  }

  String _getHeaderTitle() {
    if (errorMessage != null) return 'فشل في الإرسال';
    if (progress >= 1.0) return 'تم الإرسال بنجاح!';
    if (isUploading) return 'جاري رفع الملفات...';
    if (progress >= 0.8) return 'جاري إرسال البلاغ...';
    if (progress >= 0.5) return 'جاري التحضير...';
    return 'إعداد البلاغ';
  }
}

class ProgressStep {
  static const double dataValidation = 0.2;
  static const double mediaUploadStart = 0.3;
  static const double mediaUploadProgress = 0.6;
  static const double reportSubmission = 0.8;
  static const double notificationSent = 0.9;
  static const double completed = 1.0;
}
