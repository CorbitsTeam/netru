import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';

class VerificationStatusWidget extends StatelessWidget {
  final bool isVerified;
  final UserEntity user;
  final VoidCallback onStartVerification;

  const VerificationStatusWidget({
    super.key,
    required this.isVerified,
    required this.user,
    required this.onStartVerification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getStatusIcon(), color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getStatusDescription(),
                      style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isVerified && !user.isPendingVerification) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text('بدء التحقق من الهوية'),
              ),
            ),
          ],

          if (user.isPendingVerification) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.orange, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'سيتم مراجعة وثيقتك خلال 24-48 ساعة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isVerified && user.verifiedAt != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.green, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'تم التحقق في ${_formatDate(user.verifiedAt!)}',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isVerified) {
      return AppColors.green;
    } else if (user.isPendingVerification) {
      return AppColors.orange;
    } else if (user.isRejected) {
      return AppColors.red;
    } else {
      return AppColors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (isVerified) {
      return Icons.verified;
    } else if (user.isPendingVerification) {
      return Icons.schedule;
    } else if (user.isRejected) {
      return Icons.error;
    } else {
      return Icons.warning;
    }
  }

  String _getStatusTitle() {
    if (isVerified) {
      return 'تم التحقق من الهوية';
    } else if (user.isPendingVerification) {
      return 'في انتظار المراجعة';
    } else if (user.isRejected) {
      return 'تم رفض التحقق';
    } else {
      return 'لم يتم التحقق من الهوية';
    }
  }

  String _getStatusDescription() {
    if (isVerified) {
      return 'تم التحقق من هويتك بنجاح. يمكنك الآن استخدام جميع الخدمات.';
    } else if (user.isPendingVerification) {
      return 'تم إرسال وثائقك للمراجعة. سيتم إشعارك عند اكتمال التحقق.';
    } else if (user.isRejected) {
      return 'تم رفض طلب التحقق. يرجى المحاولة مرة أخرى بوثائق واضحة.';
    } else {
      return 'يرجى تحميل وثيقة هويتك للتحقق من حسابك والاستفادة من جميع الخدمات.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
