import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildActionButton(
                  context,
                  title: 'إدارة البلاغات',
                  subtitle: 'مراجعة وإدارة البلاغات',
                  icon: Icons.report,
                  color: Colors.blue,
                  onTap:
                      () => Navigator.pushNamed(context, Routes.adminReports),
                ),
                _buildActionButton(
                  context,
                  title: 'إدارة المستخدمين',
                  subtitle: 'إدارة حسابات المستخدمين',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, Routes.adminUsers),
                ),
                _buildActionButton(
                  context,
                  title: 'الإشعارات',
                  subtitle: 'إرسال إشعارات',
                  icon: Icons.notifications,
                  color: Colors.orange,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        Routes.adminNotifications,
                      ),
                ),
                _buildActionButton(
                  context,
                  title: 'حسابات المدراء',
                  subtitle: 'إدارة المصادقة',
                  icon: Icons.admin_panel_settings,
                  color: Colors.purple,
                  onTap:
                      () =>
                          Navigator.pushNamed(context, Routes.adminAuthManager),
                ),
                _buildActionButton(
                  context,
                  title: 'تقارير مفصلة',
                  subtitle: 'إحصائيات شاملة',
                  icon: Icons.analytics,
                  color: Colors.teal,
                  onTap: () => _showComingSoonDialog(context, 'تقارير مفصلة'),
                ),
                _buildActionButton(
                  context,
                  title: 'إعدادات النظام',
                  subtitle: 'تكوين التطبيق',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () => _showComingSoonDialog(context, 'إعدادات النظام'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 24.sp, color: color),
            ),
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('قريباً'),
            content: Text('ميزة "$feature" قيد التطوير وستكون متاحة قريباً.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }
}
