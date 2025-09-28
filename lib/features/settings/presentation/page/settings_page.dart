import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import 'package:netru_app/core/di/injection_container.dart'
    as di;
import 'package:netru_app/features/auth/domain/usecases/logout_user.dart';
import 'package:netru_app/features/settings/presentation/page/edit_profile_page.dart';
import 'package:netru_app/features/settings/presentation/widgets/notification_settings_widget.dart';
import 'package:netru_app/features/settings/presentation/widgets/support_options_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    try {
      final info =
          await PackageInfo.fromPlatform();
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
    final userHelper = UserDataHelper();
    final user = userHelper.getCurrentUser();
    final userName = userHelper.getUserFullName();

    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color:
                Theme.of(context)
                    .appBarTheme
                    .titleTextStyle
                    ?.color,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Theme.of(
              context,
            ).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme:
            Theme.of(
              context,
            ).appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              key: const ValueKey(
                'profile_header_container',
              ),
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors
                        .primaryColor
                        .withOpacity(0.1),
                    child:
                        userHelper.getUserProfileImage() !=
                                null
                            ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    userHelper
                                        .getUserProfileImage()!,
                                width: 80.r,
                                height: 80.r,
                                fit: BoxFit.cover,
                                errorWidget: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Icon(
                                    Icons.person,
                                    size: 40.r,
                                    color:
                                        AppColors
                                            .primaryColor,
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.person,
                              size: 40.r,
                              color:
                                  AppColors
                                      .primaryColor,
                            ),
                  ),
                  SizedBox(height: 12.h),
                  // User Name
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Edit Profile Button
                  SizedBox(
                    height: 30.h,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey(
                        'edit_profile_button',
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const EditProfilePage(),
                          ),
                        );
                        // Refresh user data from database and update UI
                        if (mounted) {
                          await userHelper
                              .refreshUserDataFromDatabase();
                          setState(() {
                            // This will trigger a rebuild with fresh data
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: Text(
                        'تعديل الملف الشخصي',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors
                                .primaryColor,
                        side: const BorderSide(
                          color:
                              AppColors
                                  .primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                8.r,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications Section
            _buildSettingsSection('الإشعارات', [
              Container(
                padding: EdgeInsets.all(14.w),
                child:
                    const NotificationSettingsWidget(),
              ),
            ]),

            // App Settings Section
            _buildSettingsSection('إعدادات التطبيق', [
              _buildActionTile(
                icon:
                    Icons.support_agent_outlined,
                title: 'الدعم الفني',
                subtitle:
                    'تواصل معنا للحصول على المساعدة',
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            const SupportOptionsDialog(),
                  );
                },
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.star_outline,
                title: 'تقييم التطبيق',
                subtitle: 'قيم تجربتك معنا',
                onTap: _rateApp,
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.share_outlined,
                title: 'مشاركة التطبيق',
                subtitle:
                    'شارك التطبيق مع الآخرين',
                onTap: _shareApp,
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.info_outline,
                title: 'حول التطبيق',
                subtitle:
                    'معلومات عن التطبيق والإصدار',
                onTap: _showAppInfo,
              ),
            ]),

            SizedBox(height: 16.h),

            // Account Section
            _buildSettingsSection('الحساب', [
              _buildActionTile(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                subtitle: 'خروج من الحساب الحالي',
                onTap: _showLogoutDialog,
                titleColor: AppColors.error,
                showArrow: false,
              ),
            ]),

            SizedBox(height: 32.h),

            // App version
            if (_packageInfo != null)
              Text(
                'الإصدار ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color,
                ),
              ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<Widget> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              8.h,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0.5,
      color: Theme.of(
        context,
      ).dividerColor.withValues(alpha: 0.3),
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  titleColor ??
                  AppColors.primaryColor,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          titleColor ??
                          Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _rateApp() async {
    const String appStoreUrl =
        'https://apps.apple.com/app/netru-app';
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.netru.app';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تقييم التطبيق'),
            content: const Text(
              'نتطلع لمعرفة رأيك في التطبيق! يرجى تقييمنا في المتجر.',
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).pop(),
                child: const Text('ليس الآن'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final url =
                        Theme.of(
                                  context,
                                ).platform ==
                                TargetPlatform.iOS
                            ? appStoreUrl
                            : playStoreUrl;

                    if (await canLaunchUrl(
                      Uri.parse(url),
                    )) {
                      await launchUrl(
                        Uri.parse(url),
                        mode:
                            LaunchMode
                                .externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'شكراً لك! سنعمل على إضافة رابط المتجر قريباً',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'حدث خطأ في فتح المتجر',
                          ),
                          backgroundColor:
                              Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('تقييم'),
              ),
            ],
          ),
    );
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

      await Share.share(
        shareText,
        subject: 'شارك تطبيق $appName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ في مشاركة التطبيق',
            ),
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
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                const Text('حول التطبيق'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'اسم التطبيق:',
                  'نترو',
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  'الإصدار:',
                  _packageInfo != null
                      ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})'
                      : '1.0.0',
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  'المطور:',
                  'Corbits Team',
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  'التاريخ:',
                  'سبتمبر 2025',
                ),
                SizedBox(height: 16.h),
                Text(
                  'تطبيق نترو هو منصة شاملة للتبليغ عن الجرائم والحصول على آخر الأخبار الأمنية والمعلومات المفيدة للمجتمع.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                const Text('تسجيل الخروج'),
              ],
            ),
            content: const Text(
              'هل أنت متأكد من تسجيل الخروج؟',
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleLogout();
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      AppColors.error,
                ),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(),
            ),
      );

      // Use logout usecase to logout from Supabase
      final logoutUseCase =
          di.sl<LogoutUserUseCase>();
      final result = await logoutUseCase(
        const NoParams(),
      );

      result.fold(
        (failure) {
          // Hide loading
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) async {
          // Clear user data from SharedPreferences
          await UserDataHelper()
              .clearCurrentUser();

          // Hide loading
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Navigate to login screen
          if (mounted) {
            context.pushReplacementNamed(
              Routes.loginScreen,
            );
          }
        },
      );
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.of(context).pop();

      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء تسجيل الخروج',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
