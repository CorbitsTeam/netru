import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileAdminDrawer extends StatelessWidget {
  final String? selectedRoute;
  final Function(String)? onRouteSelected;

  const MobileAdminDrawer({
    super.key,
    this.selectedRoute,
    this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          _buildDrawerHeader(context),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  route: '/admin/dashboard',
                  isSelected: selectedRoute == '/admin/dashboard',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.report_problem,
                  title: 'إدارة البلاغات',
                  route: '/admin/reports',
                  isSelected: selectedRoute == '/admin/reports',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  title: 'إدارة المستخدمين',
                  route: '/admin/users',
                  isSelected: selectedRoute == '/admin/users',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  title: 'الإشعارات',
                  route: '/admin/notifications',
                  isSelected: selectedRoute == '/admin/notifications',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.security,
                  title: 'إدارة حسابات المصادقة',
                  route: '/admin/auth-manager',
                  isSelected: selectedRoute == '/admin/auth-manager',
                ),

                const Divider(),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'المساعدة',
                  route: '/admin/help',
                  isSelected: selectedRoute == '/admin/help',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  route: '/logout',
                  isSelected: false,
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 28.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: Text(
                  'مدير النظام',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  'لوحة التحكم الإدارية',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : isLogout
                  ? Colors.red
                  : Colors.grey[600],
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : isLogout
                    ? Colors.red
                    : Colors.grey[800],
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Theme.of(context).primaryColor,
                )
                : null,
        onTap: () {
          Navigator.pop(context); // Close drawer

          if (isLogout) {
            _showLogoutDialog(context);
          } else {
            onRouteSelected?.call(route);
            // Navigate to the selected route
            _navigateToRoute(context, route);
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement logout logic
                  // context.read<AuthCubit>().logout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    switch (route) {
      case '/admin/dashboard':
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case '/admin/reports':
        Navigator.pushReplacementNamed(context, '/admin/reports');
        break;
      case '/admin/users':
        Navigator.pushReplacementNamed(context, '/admin/users');
        break;
      case '/admin/notifications':
        Navigator.pushReplacementNamed(context, '/admin/notifications');
        break;
      case '/admin/auth-manager':
        Navigator.pushReplacementNamed(context, '/admin/auth-manager');
        break;
      default:
        // Show coming soon dialog for unimplemented routes
        _showComingSoonDialog(context, route);
        break;
    }
  }

  void _showComingSoonDialog(BuildContext context, String route) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('قريباً'),
            content: const Text('هذه الميزة قيد التطوير وستكون متاحة قريباً.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }
}
