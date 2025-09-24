import 'package:flutter/material.dart';
import 'package:netru_app/core/widgets/app_widgets.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/features/auth/domain/usecases/logout_user.dart';
import 'package:netru_app/features/settings/presentation/widgets/theme_section.dart';
import 'package:netru_app/features/settings/presentation/widgets/language_section.dart';
import 'package:netru_app/features/settings/presentation/widgets/notification_settings_widget.dart';
import 'package:netru_app/features/settings/presentation/widgets/support_options_dialog.dart';
import 'package:netru_app/features/settings/presentation/widgets/settings_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: UIConstants.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            const SettingsProfileHeader(),

            // General Settings Section
            AppSection(
              title: 'الإعدادات العامة',
              children: [
                Container(
                  padding: UIConstants.paddingSymmetricMedium,
                  child: const ThemeSection(),
                ),
                const AppDivider(),
                Container(
                  padding: UIConstants.paddingSymmetricMedium,
                  child: const LanguageSection(),
                ),
              ],
            ),

            // Notifications Section
            AppSection(
              title: 'الإشعارات',
              children: [
                Container(
                  padding: UIConstants.paddingMedium,
                  child: const NotificationSettingsWidget(),
                ),
              ],
            ),

            UIConstants.verticalSpaceMedium,

            // App Settings Section
            SettingsAppInfoSection(
              onSupport: () {
                showDialog(
                  context: context,
                  builder: (context) => const SupportOptionsDialog(),
                );
              },
              onRate: _rateApp,
              onShare: _shareApp,
              onAppInfo: _showAppInfo,
            ),

            UIConstants.verticalSpaceMedium,

            // Account Section
            SettingsLogoutSection(onLogout: _showLogoutDialog),

            UIConstants.verticalSpaceExtraLarge,

            // App version
            if (_packageInfo != null)
              Text(
                'الإصدار ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                style: TextStyle(
                  fontSize: UIConstants.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),

            UIConstants.verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  void _rateApp() async {
    const String appStoreUrl = 'https://apps.apple.com/app/netru-app';
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.netru.app';

    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'تقييم التطبيق',
      content: 'نتطلع لمعرفة رأيك في التطبيق! يرجى تقييمنا في المتجر.',
      confirmText: 'متجر Google Play',
      cancelText: 'App Store',
      icon: Icons.star,
    );

    if (confirmed == true) {
      // Google Play Store
      try {
        if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
          await launchUrl(Uri.parse(playStoreUrl));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح المتجر'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (confirmed == false) {
      // App Store
      try {
        if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
          await launchUrl(Uri.parse(appStoreUrl));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح المتجر'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareApp() async {
    try {
      const String appName = 'تطبيق نترو';
      const String appDescription =
          'تطبيق رائع للتبليغ عن الجرائم والحصول على آخر الأخبار الأمنية';
      const String shareText = '''
🌟 اكتشف $appName! 

$appDescription

📱 حمّل التطبيق الآن:
🍎 App Store: https://apps.apple.com/app/netru-app
🤖 Google Play: https://play.google.com/store/apps/details?id=com.netru.app

#نترو #الأمان #التطبيقات_المفيدة
      ''';

      await Share.share(shareText, subject: 'شارك تطبيق $appName');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في مشاركة التطبيق'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: UIConstants.borderRadiusExtraLarge,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: UIConstants.iconSizeLarge,
                ),
                UIConstants.horizontalSpaceSmall,
                const Text('معلومات التطبيق'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInfoRow(
                  label: 'الاسم:',
                  value: _packageInfo?.appName ?? 'نترو',
                ),
                AppInfoRow(
                  label: 'الإصدار:',
                  value: _packageInfo?.version ?? '1.0.0',
                ),
                AppInfoRow(
                  label: 'البناء:',
                  value: _packageInfo?.buildNumber ?? '1',
                ),
                AppInfoRow(label: 'المطور:', value: 'فريق كوربيتس'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    AppConfirmationDialog.show(
      context,
      title: 'تسجيل الخروج',
      content: 'هل أنت متأكد من تسجيل الخروج؟',
      confirmText: 'تسجيل الخروج',
      confirmButtonColor: Colors.red,
      icon: Icons.logout,
      iconColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        _handleLogout();
      }
    });
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      AppLoadingDialog.show(context, message: 'جاري تسجيل الخروج...');

      // Use logout usecase to logout from Supabase
      final logoutUseCase = di.sl<LogoutUserUseCase>();
      final result = await logoutUseCase(const NoParams());

      result.fold(
        (failure) {
          // Hide loading
          if (mounted) AppLoadingDialog.hide(context);

          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في تسجيل الخروج: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) async {
          // Clear user data from SharedPreferences
          await UserDataHelper().clearCurrentUser();

          // Hide loading
          if (mounted) AppLoadingDialog.hide(context);

          // Navigate to login screen
          if (mounted) {
            context.pushNamedAndRemoveUntil(Routes.loginScreen);
          }
        },
      );
    } catch (e) {
      // Hide loading
      if (mounted) AppLoadingDialog.hide(context);

      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تسجيل الخروج'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
