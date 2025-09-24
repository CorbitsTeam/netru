import 'package:flutter/material.dart';
import 'package:netru_app/core/widgets/app_widgets.dart';
import 'package:netru_app/features/settings/presentation/page/edit_profile_page.dart';

/// Profile header widget for settings page
class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard.profile(
      child: AppProfileHeader.fromUser(
        onEditPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        },
      ),
    );
  }
}

/// Logout section widget for settings page
class SettingsLogoutSection extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsLogoutSection({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: 'الحساب',
      children: [
        AppActionTile(
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          subtitle: 'تسجيل الخروج من التطبيق',
          titleColor: Colors.red,
          iconColor: Colors.red,
          showArrow: false,
          onTap: onLogout,
        ),
      ],
    );
  }
}

/// App info section widget for settings page
class SettingsAppInfoSection extends StatelessWidget {
  final VoidCallback onSupport;
  final VoidCallback onRate;
  final VoidCallback onShare;
  final VoidCallback onAppInfo;

  const SettingsAppInfoSection({
    super.key,
    required this.onSupport,
    required this.onRate,
    required this.onShare,
    required this.onAppInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: 'إعدادات التطبيق',
      children: [
        AppActionTile(
          icon: Icons.support_agent_outlined,
          title: 'الدعم الفني',
          subtitle: 'تواصل معنا للحصول على المساعدة',
          onTap: onSupport,
        ),
        const AppDivider(),
        AppActionTile(
          icon: Icons.star_outline,
          title: 'تقييم التطبيق',
          subtitle: 'قيم تجربتك معنا',
          onTap: onRate,
        ),
        const AppDivider(),
        AppActionTile(
          icon: Icons.share_outlined,
          title: 'مشاركة التطبيق',
          subtitle: 'شارك التطبيق مع الآخرين',
          onTap: onShare,
        ),
        const AppDivider(),
        AppActionTile(
          icon: Icons.info_outline,
          title: 'معلومات التطبيق',
          subtitle: 'الإصدار والمطور',
          onTap: onAppInfo,
        ),
      ],
    );
  }
}
