import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ProgressDialog extends StatelessWidget {
  final double progress;
  final String currentStep;
  final bool isUploading;
  final int? uploadedFiles;
  final int? totalFiles;
  final String? errorMessage;

  const ProgressDialog({
    super.key,
    required this.progress,
    required this.currentStep,
    this.isUploading = false,
    this.uploadedFiles,
    this.totalFiles,
    this.errorMessage,
  });

  static void show(
    BuildContext context, {
    required double progress,
    required String currentStep,
    bool isUploading = false,
    int? uploadedFiles,
    int? totalFiles,
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ProgressDialog(
            progress: progress,
            currentStep: currentStep,
            isUploading: isUploading,
            uploadedFiles: uploadedFiles,
            totalFiles: totalFiles,
            errorMessage: errorMessage,
          ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by back button
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                spreadRadius: 5.r,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildProgressSection(),
              if (isUploading && totalFiles != null && totalFiles! > 0) ...[
                SizedBox(height: 20.h),
                _buildFileUploadProgress(),
              ],
              if (errorMessage != null) ...[
                SizedBox(height: 20.h),
                _buildErrorMessage(),
              ],
              SizedBox(height: 16.h),
              _buildStepIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 28.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getHeaderTitle(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                currentStep,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Progress bar
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(),
                          _getStatusColor().withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  // Animated shimmer effect
                  if (progress < 1.0)
                    Positioned(
                      left: constraints.maxWidth * progress - 30.w,
                      child: Container(
                        width: 30.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadProgress() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_upload, color: Colors.blue[600], size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رفع الملفات',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${uploadedFiles ?? 0} من ${totalFiles ?? 0} ملف',
                  style: TextStyle(fontSize: 12.sp, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
          Text(
            '${uploadedFiles ?? 0} / ${totalFiles ?? 0}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicators() {
    final steps = [
      {'label': 'البيانات', 'threshold': 0.2},
      {'label': 'الملفات', 'threshold': 0.6},
      {'label': 'الإرسال', 'threshold': 0.9},
      {'label': 'مكتمل', 'threshold': 1.0},
    ];

    return Row(
      children:
          steps.map((step) {
            final isCompleted = progress >= (step['threshold'] as double);
            final isActive =
                progress >= (step['threshold'] as double) - 0.2 &&
                progress < (step['threshold'] as double);

            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? _getStatusColor().withOpacity(0.1)
                          : isActive
                          ? _getStatusColor().withOpacity(0.05)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color:
                        isCompleted
                            ? _getStatusColor()
                            : isActive
                            ? _getStatusColor().withOpacity(0.3)
                            : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isCompleted
                              ? _getStatusColor()
                              : isActive
                              ? _getStatusColor().withOpacity(0.7)
                              : Colors.grey[400],
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        step['label'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                              isCompleted ? FontWeight.bold : FontWeight.normal,
                          color:
                              isCompleted
                                  ? _getStatusColor()
                                  : isActive
                                  ? Colors.black87
                                  : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
    return Icons.assignment_turned_in;
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
