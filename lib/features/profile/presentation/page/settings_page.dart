import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/features/auth/domain/usecases/logout_user.dart';
import 'package:netru_app/features/profile/presentation/page/edit_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  bool isLocationEnabled = true;
  String selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    final userHelper = UserDataHelper();
    final user = userHelper.getCurrentUser();
    final userName = userHelper.getUserFullName();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // User Profile Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.grey[200],
                    child:
                        userHelper.getUserProfileImage() != null
                            ? ClipOval(
                              child: Image.network(
                                userHelper.getUserProfileImage()!,
                                width: 60.r,
                                height: 60.r,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30.r,
                                    color: Colors.grey[600],
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.person,
                              size: 30.r,
                              color: Colors.grey[600],
                            ),
                  ),
                  SizedBox(width: 16.w),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user?.email ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Appearance Settings
            _buildSettingsSection('المظهر', [
              _buildSwitchTile(
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'الوضع المظلم',
                subtitle: 'تفعيل الوضع المظلم للتطبيق',
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
              _buildLanguageTile(),
            ]),
            SizedBox(height: 20.h),

            // Notifications Settings
            _buildSettingsSection('الإشعارات', [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'الإشعارات',
                subtitle: 'تلقي إشعارات من التطبيق',
                value: isNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    isNotificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'خدمات الموقع',
                subtitle: 'السماح للتطبيق بالوصول للموقع',
                value: isLocationEnabled,
                onChanged: (value) {
                  setState(() {
                    isLocationEnabled = value;
                  });
                },
              ),
            ]),
            SizedBox(height: 20.h),

            // Account Settings
            _buildSettingsSection('الحساب', [
              _buildActionTile(
                icon: Icons.person_outline,
                title: 'تعديل الملف الشخصي',
                subtitle: 'تحديث بياناتك الشخصية',
                onTap: () {
                  // Navigate to edit profile
                },
              ),
              _buildActionTile(
                icon: Icons.lock_outline,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة مرور حسابك',
                onTap: () {
                  // Navigate to change password
                },
              ),
              _buildActionTile(
                icon: Icons.security,
                title: 'الأمان والخصوصية',
                subtitle: 'إعدادات الأمان والخصوصية',
                onTap: () {
                  // Navigate to security settings
                },
              ),
            ]),
            SizedBox(height: 20.h),

            // Support Settings
            _buildSettingsSection('الدعم والمساعدة', [
              _buildActionTile(
                icon: Icons.help_outline,
                title: 'مركز المساعدة',
                subtitle: 'الأسئلة الشائعة والدعم',
                onTap: () {
                  // Navigate to help center
                },
              ),
              _buildActionTile(
                icon: Icons.contact_support,
                title: 'تواصل معنا',
                subtitle: 'إرسال رسالة للدعم الفني',
                onTap: () {
                  _contactSupport();
                },
              ),
              _buildActionTile(
                icon: Icons.star_outline,
                title: 'تقييم التطبيق',
                subtitle: 'قيم التطبيق في المتجر',
                onTap: () {
                  _rateApp();
                },
              ),
              _buildActionTile(
                icon: Icons.share,
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق مع الأصدقاء',
                onTap: () {
                  _shareApp();
                },
              ),
            ]),
            SizedBox(height: 20.h),

            // About Settings
            _buildSettingsSection('حول التطبيق', [
              _buildActionTile(
                icon: Icons.info_outline,
                title: 'معلومات التطبيق',
                subtitle: 'الإصدار 1.0.0',
                onTap: () {
                  _showAppInfo();
                },
              ),
              _buildActionTile(
                icon: Icons.description,
                title: 'شروط الاستخدام',
                subtitle: 'قراءة شروط وأحكام الاستخدام',
                onTap: () {
                  // Navigate to terms
                },
              ),
              _buildActionTile(
                icon: Icons.privacy_tip,
                title: 'سياسة الخصوصية',
                subtitle: 'قراءة سياسة الخصوصية',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
            ]),
            SizedBox(height: 20.h),

            // Logout Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    subtitle: 'الخروج من حسابك الحالي',
                    titleColor: Colors.red,
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.primaryColor).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                color: titleColor ?? AppColors.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return InkWell(
      onTap: _showLanguageDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.language,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اللغة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selectedLanguage,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('اختر اللغة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'العربية',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'English',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _contactSupport() async {
    const email = 'support@netruapp.com';
    const subject = 'طلب دعم فني';
    const body = 'يرجى وصف مشكلتك هنا...';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح تطبيق البريد الإلكتروني'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء فتح تطبيق البريد الإلكتروني'),
          ),
        );
      }
    }
  }

  void _rateApp() async {
    const String appStoreUrl = 'https://apps.apple.com/app/your-app-id';
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=your.package.name';

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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ليس الآن'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final url =
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? appStoreUrl
                            : playStoreUrl;

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'شكراً لك! يرجى البحث عن التطبيق في المتجر وتقييمه.',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'شكراً لك! يرجى البحث عن التطبيق في المتجر وتقييمه.',
                          ),
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

  void _shareApp() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة وظيفة المشاركة قريباً')),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('معلومات التطبيق'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم التطبيق: نترو'),
                SizedBox(height: 8.h),
                Text('الإصدار: 1.0.0'),
                SizedBox(height: 8.h),
                Text('تاريخ آخر تحديث: 5 سبتمبر 2025'),
                SizedBox(height: 8.h),
                Text('المطور: فريق نترو'),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text(
              'هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleLogout();
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red),
                ),
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
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Use logout usecase to logout from Supabase
      final logoutUseCase = di.sl<LogoutUserUseCase>();
      final result = await logoutUseCase(const NoParams());

      result.fold(
        (failure) {
          // Hide loading
          if (mounted) Navigator.of(context).pop();

          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) async {
          // Clear user data from SharedPreferences
          await UserDataHelper().clearCurrentUser();

          // Hide loading
          if (mounted) Navigator.of(context).pop();

          // Navigate to login screen
          if (mounted) {
            context.pushReplacementNamed(Routes.loginScreen);
          }
        },
      );
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.of(context).pop();

      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
