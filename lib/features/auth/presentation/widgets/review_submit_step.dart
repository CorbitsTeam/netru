import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';

class ReviewSubmitStep extends StatelessWidget {
  final UserType userType;
  final Map<String, String> userData;
  final Map<String, String> locationData;
  final List<String> documentPaths;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const ReviewSubmitStep({
    super.key,
    required this.userType,
    required this.userData,
    required this.locationData,
    required this.documentPaths,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // Title
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'مراجعة البيانات والإرسال',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          FadeInDown(
            duration: const Duration(milliseconds: 700),
            child: Text(
              'تأكد من صحة جميع البيانات قبل إرسال طلب التسجيل',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Personal Information Section
                  _buildReviewSection(
                    title: 'البيانات الشخصية',
                    icon: Icons.person_outline,
                    items: _getPersonalDataItems(),
                    animationDelay: 0,
                  ),

                  SizedBox(height: 20.h),

                  // Contact Information Section
                  _buildReviewSection(
                    title: 'بيانات التواصل',
                    icon: Icons.contact_phone_outlined,
                    items: _getContactDataItems(),
                    animationDelay: 100,
                  ),

                  SizedBox(height: 20.h),

                  // Location Information Section
                  _buildReviewSection(
                    title: 'العنوان',
                    icon: Icons.location_on_outlined,
                    items: _getLocationDataItems(),
                    animationDelay: 200,
                  ),

                  if (userType == UserType.foreigner) ...[
                    SizedBox(height: 20.h),
                    _buildReviewSection(
                      title: 'بيانات جواز السفر',
                      icon: Icons.assignment_outlined,
                      items: _getPassportDataItems(),
                      animationDelay: 300,
                    ),
                  ],

                  SizedBox(height: 20.h),

                  // Documents Section
                  _buildDocumentsSection(),

                  SizedBox(height: 32.h),

                  // Terms and Conditions
                  _buildTermsSection(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Submit Button
          // _buildSubmitButton(),
        ],
      ),
    );
  }

  List<ReviewItem> _getPersonalDataItems() {
    return [
      ReviewItem(
        label: 'الاسم الكامل',
        value: userData['fullName'] ?? 'غير محدد',
      ),
      ReviewItem(
        label: userType == UserType.citizen ? 'الرقم القومي' : 'رقم الهوية',
        value: userData['nationalId'] ?? 'غير محدد',
      ),
      ReviewItem(
        label: 'تاريخ الميلاد',
        value: userData['birthDate'] ?? 'غير محدد',
      ),
      ReviewItem(
        label: 'نوع المستخدم',
        value: userType == UserType.citizen ? 'مواطن مصري' : 'مقيم أجنبي',
      ),
    ];
  }

  List<ReviewItem> _getContactDataItems() {
    return [
      ReviewItem(label: 'رقم الهاتف', value: userData['phone'] ?? 'غير محدد'),
      ReviewItem(
        label: 'البريد الإلكتروني',
        value: userData['email'] ?? 'غير محدد',
      ),
    ];
  }

  List<ReviewItem> _getLocationDataItems() {
    return [
      ReviewItem(
        label: 'المحافظة',
        value: locationData['governorate'] ?? 'غير محددة',
      ),
      ReviewItem(label: 'المدينة', value: locationData['city'] ?? 'غير محددة'),
    ];
  }

  List<ReviewItem> _getPassportDataItems() {
    return [
      ReviewItem(
        label: 'رقم جواز السفر',
        value: userData['passportNumber'] ?? 'غير محدد',
      ),
      ReviewItem(
        label: 'الجنسية',
        value: userData['nationality'] ?? 'غير محددة',
      ),
      ReviewItem(
        label: 'تاريخ إصدار الجواز',
        value: userData['passportIssueDate'] ?? 'غير محدد',
      ),
      ReviewItem(
        label: 'تاريخ انتهاء الجواز',
        value: userData['passportExpiryDate'] ?? 'غير محدد',
      ),
    ];
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<ReviewItem> items,
    required int animationDelay,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800 + animationDelay),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Items
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: items.map((item) => _buildReviewItem(item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '${item.label} : ',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              item.value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.attach_file_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'المستندات المرفقة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Documents
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  if (documentPaths.isNotEmpty) ...[
                    ...documentPaths.asMap().entries.map((entry) {
                      int index = entry.key;
                      String documentName = _getDocumentName(index);

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                documentName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'لم يتم رفع أي مستندات',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDocumentName(int index) {
    if (userType == UserType.citizen) {
      return index == 0
          ? 'الوجه الأمامي للبطاقة الشخصية'
          : 'الوجه الخلفي للبطاقة الشخصية';
    } else {
      return 'جواز السفر';
    }
  }

  Widget _buildTermsSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.info.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'تأكيد وموافقة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'بالضغط على "إرسال الطلب"، أؤكد أن جميع البيانات المدخلة صحيحة وأوافق على شروط وأحكام استخدام الخدمة.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1300),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
          ),
          child:
              isSubmitting
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'جاري إرسال الطلب...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'إرسال الطلب',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class ReviewItem {
  final String label;
  final String value;

  const ReviewItem({required this.label, required this.value});
}
