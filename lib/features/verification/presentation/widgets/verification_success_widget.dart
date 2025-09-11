import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/extracted_document_data.dart';

class VerificationSuccessWidget extends StatelessWidget {
  final IdentityDocument document;
  final ExtractedDocumentData extractedData;
  final VoidCallback onContinue;

  const VerificationSuccessWidget({
    super.key,
    required this.document,
    required this.extractedData,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // Success animation
          Lottie.asset(
            AppAssets.lottieAll, // You can create a success-specific animation
            width: 150.w,
            height: 150.h,
            repeat: false,
          ),

          SizedBox(height: 32.h),

          // Success message
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.green.withOpacity(0.1),
                  AppColors.green.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.verified, color: AppColors.green, size: 40.sp),
                SizedBox(height: 16.h),
                Text(
                  'تم إرسال طلب التحقق بنجاح!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'تم حفظ وثيقة الهوية الخاصة بك بنجاح. سيتم مراجعتها من قبل فريقنا المختص.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Document info
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getDocumentIcon(),
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'تفاصيل الوثيقة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildInfoRow('نوع الوثيقة', _getDocumentTypeName()),
                SizedBox(height: 12.h),
                _buildInfoRow('الاسم', extractedData.fullName),
                SizedBox(height: 12.h),
                _buildInfoRow('رقم الوثيقة', extractedData.documentNumber),
                SizedBox(height: 12.h),
                _buildInfoRow('حالة التحقق', 'قيد المراجعة'),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Next steps
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'الخطوات التالية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildStepItem('سيتم مراجعة وثيقتك خلال 24-48 ساعة'),
                _buildStepItem('ستصلك إشعار عند اكتمال التحقق'),
                _buildStepItem('يمكنك متابعة حالة التحقق من الملف الشخصي'),
              ],
            ),
          ),

          const Spacer(),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                'المتابعة إلى الملف الشخصي',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.grey)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            margin: EdgeInsets.only(top: 6.h, right: 8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    switch (document.type) {
      case DocumentType.nationalId:
        return Icons.credit_card;
      case DocumentType.passport:
        return Icons.import_contacts;
    }
  }

  String _getDocumentTypeName() {
    switch (document.type) {
      case DocumentType.nationalId:
        return 'بطاقة الرقم القومي';
      case DocumentType.passport:
        return 'جواز السفر';
    }
  }
}
