import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
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
                  title: 'إرسال الإشعارات',
                  subtitle: 'إرسال إشعارات للمستخدمين',
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
                  title: 'إدارة حسابات المصادقة',
                  subtitle: 'إدارة صلاحيات المديرين',
                  icon: Icons.admin_panel_settings,
                  color: Colors.purple,
                  onTap:
                      () =>
                          Navigator.pushNamed(context, Routes.adminAuthManager),
                ),
                _buildActionButton(
                  context,
                  title: 'تقارير مفصلة',
                  subtitle: 'عرض التقارير والإحصائيات',
                  icon: Icons.analytics,
                  color: Colors.teal,
                  onTap: () => _showComingSoonDialog(context, 'تقارير مفصلة'),
                ),
                _buildActionButton(
                  context,
                  title: 'إعدادات النظام',
                  subtitle: 'تكوين إعدادات النظام',
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
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
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
