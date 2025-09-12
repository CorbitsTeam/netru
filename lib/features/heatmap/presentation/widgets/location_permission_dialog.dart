import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';

class LocationPermissionDialog
    extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 300.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الموقع
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),

            SizedBox(height: 20.h),

            // العنوان
            Text(
              'تفعيل خدمة الموقع',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            // الوصف
            Text(
              'للحصول على أفضل تجربة، نحتاج للوصول إلى موقعك لعرض الخريطة الحرارية للجرائم في منطقتك',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // المميزات
            _buildFeatureItem(
              icon: Icons.map,
              text: 'عرض الخريطة الحرارية لموقعك',
            ),

            SizedBox(height: 8.h),

            _buildFeatureItem(
              icon: Icons.security,
              text:
                  'تحديد مستوى الأمان في منطقتك',
            ),

            SizedBox(height: 8.h),

            _buildFeatureItem(
              icon: Icons.navigation,
              text:
                  'إظهار موقعك الحالي على الخريطة',
            ),

            SizedBox(height: 24.h),

            // الأزرار
            Row(
              children: [
                // زر الرفض
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(false),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(
                              vertical: 12.h),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                25.r),
                        side: BorderSide(
                          color:
                              Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // زر الموافقة
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _requestPermission(
                            context),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor,
                      padding:
                          EdgeInsets.symmetric(
                              vertical: 12.h),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                25.r),
                      ),
                    ),
                    child: Text(
                      'السماح',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestPermission(
      BuildContext context) async {
    try {
      // فحص إذا كانت خدمة الموقع مفعلة
      bool serviceEnabled = await Geolocator
          .isLocationServiceEnabled();
      if (!serviceEnabled) {
        // إظهار رسالة لتفعيل خدمة الموقع
        _showServiceDisabledDialog(context);
        return;
      }

      // طلب الصلاحية
      LocationPermission permission =
          await Geolocator.requestPermission();

      if (permission ==
              LocationPermission.whileInUse ||
          permission ==
              LocationPermission.always) {
        Navigator.of(context).pop(true);
      } else if (permission ==
          LocationPermission.deniedForever) {
        _showPermissionDeniedDialog(context);
      } else {
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      Navigator.of(context).pop(false);
    }
  }

  void _showServiceDisabledDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.r),
        ),
        title:
            const Text('خدمة الموقع غير مفعلة'),
        content: const Text(
          'يرجى تفعيل خدمة الموقع من إعدادات الجهاز للمتابعة',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator
                  .openLocationSettings();
              Navigator.of(context).pop(false);
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.r),
        ),
        title: const Text('صلاحية الموقع مرفوضة'),
        content: const Text(
          'تم رفض صلاحية الموقع نهائياً. يرجى تفعيلها من إعدادات التطبيق',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
              Navigator.of(context).pop(false);
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
}
