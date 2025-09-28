import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ReportSubmissionProgressDialog extends StatefulWidget {
  final double progress; // From 0.0 to 1.0
  final String currentStep;
  final bool isUploading;
  final int? uploadedFiles;
  final int? totalFiles;
  final String? errorMessage;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const ReportSubmissionProgressDialog({
    super.key,
    required this.progress,
    required this.currentStep,
    this.isUploading = false,
    this.uploadedFiles,
    this.totalFiles,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
    this.onClose,
  });

  @override
  State<ReportSubmissionProgressDialog> createState() =>
      _ReportSubmissionProgressDialogState();

  static Future<T?> show<T>(
    BuildContext context, {
    required double progress,
    required String currentStep,
    bool isUploading = false,
    int? uploadedFiles,
    int? totalFiles,
    String? errorMessage,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ReportSubmissionProgressDialog(
          progress: progress,
          currentStep: currentStep,
          isUploading: isUploading,
          uploadedFiles: uploadedFiles,
          totalFiles: totalFiles,
          errorMessage: errorMessage,
          onCancel: onCancel,
          onRetry: onRetry,
          onClose: onClose,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeInBack,
        );

        return Transform.scale(
          scale: curvedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 50),
            child: Opacity(opacity: animation.value, child: child),
          ),
        );
      },
    );
  }
}

class _ReportSubmissionProgressDialogState
    extends State<ReportSubmissionProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(seconds: 5), // Realistic duration for progress
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    if (widget.progress < 1.0) {
      _shimmerController.repeat();
      _pulseController.repeat(reverse: true);
      _progressController.forward();
    }

    if (widget.isUploading) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ReportSubmissionProgressDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressController.reset();
      _progressAnimation = Tween<double>(begin: oldWidget.progress, end: widget.progress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward();
    }
    if (widget.progress >= 1.0 && oldWidget.progress < 1.0) {
      _shimmerController.stop();
      _pulseController.stop();
      _rotationController.stop();
    } else if (widget.progress < 1.0 && oldWidget.progress >= 1.0) {
      _shimmerController.repeat();
      _pulseController.repeat(reverse: true);
    }
    if (widget.isUploading && !oldWidget.isUploading) {
      _rotationController.repeat();
    } else if (!widget.isUploading && oldWidget.isUploading) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _shimmerController,
          _pulseController,
          _rotationController,
          _progressController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUploading ? _pulseAnimation.value : 1.0,
            child: Container(
              constraints: BoxConstraints(maxHeight: 0.8.sh),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    widget.errorMessage != null
                        ? Colors.red[50]!
                        : widget.progress >= 1.0
                            ? Colors.green[50]!
                            : AppColors.primaryColor.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.errorMessage != null
                        ? Colors.red.withOpacity(0.2)
                        : widget.progress >= 1.0
                            ? Colors.green.withOpacity(0.2)
                            : AppColors.primaryColor.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    spreadRadius: -5,
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: Border.all(
                  color: widget.errorMessage != null
                      ? Colors.red.withOpacity(0.3)
                      : widget.progress >= 1.0
                          ? Colors.green.withOpacity(0.3)
                          : AppColors.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 24.h),
                            _buildProgressBar(),
                            SizedBox(height: 20.h),
                            _buildProgressInfo(),
                            if (widget.isUploading &&
                                widget.uploadedFiles != null &&
                                widget.totalFiles != null) ...[
                              SizedBox(height: 20.h),
                              _buildFileUploadProgress(),
                            ],
                            if (widget.errorMessage != null) ...[
                              SizedBox(height: 20.h),
                              _buildErrorMessage(),
                            ],
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor().withOpacity(0.05),
            _getStatusColor().withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor().withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor().withOpacity(0.15),
                  _getStatusColor().withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: widget.isUploading
                ? Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 28.sp,
                    ),
                  )
                : Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 28.sp,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
                if (widget.currentStep.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    widget.currentStep,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.progress < 1.0 && widget.errorMessage == null)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                ),
              ),
            ),
        ],
      ),
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
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor().withOpacity(0.15),
                    _getStatusColor().withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 5000), // Smoother transition
                    curve: Curves.easeOutCubic,
                    width: _progressAnimation.value * constraints.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: widget.errorMessage != null
                            ? [Colors.red.shade400, Colors.red.shade300]
                            : widget.progress >= 1.0
                                ? [Colors.green.shade400, Colors.green.shade300]
                                : [
                                    _getStatusColor(),
                                    _getStatusColor().withOpacity(0.7),
                                  ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor().withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  if (_progressAnimation.value < 1.0 && _progressAnimation.value > 0)
                    Positioned(
                      left: (_progressAnimation.value * constraints.maxWidth) +
                          (_shimmerAnimation.value * 50.w) -
                          25.w,
                      child: Container(
                        width: 50.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildProgressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'خطوات التقدم',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        _buildStepIndicator('البيانات', widget.progress >= ProgressStep.dataValidation, 'التحقق من صحة البيانات المدخلة'),
        SizedBox(height: 8.h),
        _buildStepIndicator('الملفات', widget.progress >= ProgressStep.mediaUploadProgress, 'رفع الملفات والصور'),
        SizedBox(height: 8.h),
        _buildStepIndicator('الإرسال', widget.progress >= ProgressStep.reportSubmission, 'إرسال البلاغ إلى الخادم'),
        SizedBox(height: 8.h),
        _buildStepIndicator('مكتمل', widget.progress >= ProgressStep.completed, 'اكتمال العملية بنجاح'),
      ],
    );
  }

  Widget _buildStepIndicator(String label, bool isCompleted, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getStatusColor().withOpacity(0.2),
                  _getStatusColor().withOpacity(0.08),
                ],
              )
            : LinearGradient(colors: [Colors.grey[50]!, Colors.grey[100]!]),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCompleted ? _getStatusColor().withOpacity(0.4) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              size: 20.sp,
              color: isCompleted ? _getStatusColor() : Colors.grey[400],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted ? _getStatusColor() : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isCompleted ? _getStatusColor().withOpacity(0.8) : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadProgress() {
    final uploadProgress = (widget.uploadedFiles! / widget.totalFiles!);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.blue[50]!.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[100]!, Colors.blue[50]!],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: Colors.blue[700],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رفع الملفات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تم رفع ${widget.uploadedFiles} من ${widget.totalFiles} ملف',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[100]!, Colors.blue[50]!],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Text(
                  '${(uploadProgress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.blue[200]!, width: 0.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: uploadProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[50]!.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[100]!, Colors.red[50]!],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.errorMessage!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.red[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          if (widget.progress < 1.0 && widget.errorMessage == null)
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          if (widget.errorMessage != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onRetry ?? () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  side: BorderSide(color: Colors.red[300]!, width: 1.5),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          if (widget.progress >= 1.0 || widget.errorMessage != null)
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  backgroundColor: _getStatusColor(),
                  elevation: 4,
                  shadowColor: _getStatusColor().withOpacity(0.3),
                ),
                child: Text(
                  widget.progress >= 1.0 ? 'موافق' : 'إغلاق',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.errorMessage != null) return Colors.red;
    if (widget.progress >= 1.0) return Colors.green;
    if (widget.isUploading) return Colors.blue;
    return AppColors.primaryColor;
  }

  IconData _getStatusIcon() {
    if (widget.errorMessage != null) return Icons.error;
    if (widget.progress >= 1.0) return Icons.check_circle;
    if (widget.isUploading) return Icons.cloud_upload;
    return Icons.assignment_turned_in;
  }

  String _getHeaderTitle() {
    if (widget.errorMessage != null) return 'فشل في الإرسال';
    if (widget.progress >= 1.0) return 'تم الإرسال بنجاح! 🎉';
    if (widget.isUploading) return 'جاري رفع الملفات... ☁️';
    if (widget.progress >= 0.8) return 'جاري إرسال البلاغ... 📤';
    if (widget.progress >= 0.5) return 'جاري التحضير... ⚙️';
    return 'إعداد البلاغ 📝';
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