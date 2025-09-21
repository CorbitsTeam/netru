import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';

class AdminSidebar extends StatelessWidget {
  final String? selectedRoute;
  final Function(String)? onRouteSelected;

  const AdminSidebar({Key? key, this.selectedRoute, this.onRouteSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'لوحة الإدارة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'نتروو - التقارير الذكية',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavSection(context, 'الرئيسية', [
                  NavItem(
                    route: '/admin/dashboard',
                    title: 'لوحة التحكم',
                    icon: Icons.dashboard,
                  ),
                  NavItem(
                    route: '/admin/analytics',
                    title: 'التحليلات',
                    icon: Icons.analytics,
                  ),
                ]),

                _buildNavSection(context, 'إدارة البلاغات', [
                  NavItem(
                    route: '/admin/reports',
                    title: 'جميع البلاغات',
                    icon: Icons.report,
                    badge: '12', // Example badge for pending reports
                  ),
                  NavItem(
                    route: '/admin/reports/pending',
                    title: 'البلاغات المعلقة',
                    icon: Icons.pending,
                  ),
                  NavItem(
                    route: '/admin/reports/investigation',
                    title: 'قيد التحقيق',
                    icon: Icons.search,
                  ),
                  NavItem(
                    route: '/admin/reports/assign',
                    title: 'تعيين المحققين',
                    icon: Icons.assignment_ind,
                  ),
                ]),

                _buildNavSection(context, 'إدارة المستخدمين', [
                  NavItem(
                    route: '/admin/users',
                    title: 'جميع المستخدمين',
                    icon: Icons.people,
                  ),
                  NavItem(
                    route: '/admin/users/verification',
                    title: 'طلبات التحقق',
                    icon: Icons.verified_user,
                    badge: '5',
                  ),
                  NavItem(
                    route: '/admin/users/admins',
                    title: 'إدارة المديرين',
                    icon: Icons.admin_panel_settings,
                  ),
                  NavItem(
                    route: '/admin/users/permissions',
                    title: 'الصلاحيات',
                    icon: Icons.security,
                  ),
                ]),

                _buildNavSection(context, 'الإشعارات', [
                  NavItem(
                    route: '/admin/notifications',
                    title: 'جميع الإشعارات',
                    icon: Icons.notifications,
                  ),
                  NavItem(
                    route: '/admin/notifications/send',
                    title: 'إرسال إشعار',
                    icon: Icons.send,
                  ),
                  NavItem(
                    route: '/admin/notifications/scheduled',
                    title: 'المجدولة',
                    icon: Icons.schedule,
                  ),
                ]),

                _buildNavSection(context, 'المحتوى', [
                  NavItem(
                    route: '/admin/news',
                    title: 'إدارة الأخبار',
                    icon: Icons.article,
                  ),
                  NavItem(
                    route: '/admin/content',
                    title: 'إدارة المحتوى',
                    icon: Icons.content_copy,
                  ),
                ]),

                _buildNavSection(context, 'النظام', [
                  NavItem(
                    route: '/admin/settings',
                    title: 'الإعدادات',
                    icon: Icons.settings,
                  ),
                  NavItem(
                    route: '/admin/logs',
                    title: 'سجلات النظام',
                    icon: Icons.history,
                  ),
                  NavItem(
                    route: '/admin/backup',
                    title: 'النسخ الاحتياطي',
                    icon: Icons.backup,
                  ),
                ]),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('المساعدة'),
                  onTap: () {
                    // Handle help
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('تسجيل الخروج'),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection(
    BuildContext context,
    String title,
    List<NavItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        ...items.map((item) => _buildNavItem(context, item)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item) {
    final isSelected = selectedRoute == item.route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          size: 20,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing:
            item.badge != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        onTap: () {
          onRouteSelected?.call(item.route);
          // Navigation logic
          if (item.route.startsWith('/admin/')) {
            _navigateToAdminRoute(context, item.route);
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
            content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle logout
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
    );
  }

  void _navigateToAdminRoute(BuildContext context, String route) {
    switch (route) {
      case '/admin/dashboard':
        Navigator.pushNamed(context, Routes.adminDashboard);
        break;
      case '/admin/reports':
        Navigator.pushNamed(context, Routes.adminReports);
        break;
      case '/admin/users':
        Navigator.pushNamed(context, Routes.adminUsers);
        break;
      case '/admin/notifications':
        Navigator.pushNamed(context, Routes.adminNotifications);
        break;
      case '/admin/users/admins':
        Navigator.pushNamed(context, Routes.adminAuthManager);
        break;
      default:
        // For routes not yet implemented, show a coming soon dialog
        _showComingSoonDialog(context, route);
    }
  }

  void _showComingSoonDialog(BuildContext context, String route) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('قريباً'),
            content: Text('هذه الصفحة قيد التطوير.\nالمسار: $route'),
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

class NavItem {
  final String route;
  final String title;
  final IconData icon;
  final String? badge;

  NavItem({
    required this.route,
    required this.title,
    required this.icon,
    this.badge,
  });
}

class AdminBottomBar extends StatelessWidget {
  const AdminBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 8),
                Text('متصل', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            Text(
              'نسخة 1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
