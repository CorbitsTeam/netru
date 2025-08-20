import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class PermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  final String title;
  final String description;
  final IconData icon;

  const PermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20.r),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 40.sp,
                color: AppColors.primaryColor,
              ),
            ),

            SizedBox(height: 20.h),

            // العنوان
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDeny,
                    style:
                        OutlinedButton.styleFrom(
                      side: BorderSide(
                          color:
                              Colors.grey[300]!),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12.r),
                      ),
                      padding:
                          EdgeInsets.symmetric(
                              vertical: 12.h),
                    ),
                    child: Text(
                      'رفض',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllow,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12.r),
                      ),
                      padding:
                          EdgeInsets.symmetric(
                              vertical: 12.h),
                    ),
                    child: Text(
                      'موافق',
                      style: TextStyle(
                        fontSize: 14.sp,
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
}

class LocationServiceDialog
    extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onCancel;

  const LocationServiceDialog({
    super.key,
    required this.onEnable,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      title: 'تفعيل خدمة الموقع',
      description:
          'يحتاج التطبيق إلى تفعيل خدمة الموقع للعمل بشكل صحيح. يرجى تفعيل الموقع من الإعدادات.',
      icon: Icons.location_on,
      onAllow: onEnable,
      onDeny: onCancel,
    );
  }
}

// حوار لطلب فتح إعدادات التطبيق
class AppSettingsDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;

  const AppSettingsDialog({
    super.key,
    required this.onOpenSettings,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      title: 'صلاحيات مطلوبة',
      description:
          'تم رفض الصلاحيات نهائياً. يرجى فتح إعدادات التطبيق وتفعيل صلاحية الموقع يدوياً.',
      icon: Icons.settings,
      onAllow: onOpenSettings,
      onDeny: onCancel,
    );
  }
}
