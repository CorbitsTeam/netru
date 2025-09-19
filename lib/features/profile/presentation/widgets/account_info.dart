import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/features/auth/domain/usecases/logout_user.dart';
import 'package:netru_app/features/profile/presentation/widgets/custom_account_info_row.dart';
import 'package:netru_app/features/profile/presentation/widgets/custom_button.dart';
import 'package:netru_app/features/profile/presentation/widgets/language_section.dart';
import 'package:netru_app/features/profile/presentation/widgets/theme_section.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  Future<void> _handleLogout(BuildContext context) async {
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
          if (context.mounted) Navigator.of(context).pop();

          // Show error message
          if (context.mounted) {
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
          if (context.mounted) Navigator.of(context).pop();

          // Navigate to login screen
          if (context.mounted) {
            context.pushReplacementNamed(Routes.loginScreen);
          }
        },
      );
    } catch (e) {
      // Hide loading
      if (context.mounted) Navigator.of(context).pop();

      // Show error message if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPersonalInfoDialog() {
    final userHelper = UserDataHelper();
    final user = userHelper.getCurrentUser();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('المعلومات الشخصية'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow('الاسم الكامل:', user?.fullName ?? 'غير محدد'),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    'البريد الإلكتروني:',
                    user?.email ?? 'غير محدد',
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoRow('رقم الهاتف:', user?.phone ?? 'غير محدد'),
                  SizedBox(height: 10.h),
                  _buildInfoRow('الموقع:', user?.location ?? 'غير محدد'),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    'الرقم القومي:',
                    user?.nationalId ?? 'غير محدد',
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    'رقم الجواز:',
                    user?.passportNumber ?? 'غير محدد',
                  ),
                ],
              ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  void _rateApp() async {
    const String appStoreUrl = 'https://apps.apple.com/app/your-app-id';
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=your.package.name';

    // Show dialog with rating options
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
                  // Try to open app store/play store
                  try {
                    final url =
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? appStoreUrl
                            : playStoreUrl;

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      // Fallback - show thanks message
                      if (context.mounted) {
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
                    if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAccountInfoRow(
          title: 'المعلومات شخصيه',
          icon: Icons.person_outline,
          onTap: _showPersonalInfoDialog,
        ),
        SizedBox(height: 30.h),
        const CustomAccountInfoRow(
          title: 'تغيير كلمة المرور',
          icon: Icons.lock_outline,
          onTap: null,
        ),
        SizedBox(height: 30.h),
        CustomAccountInfoRow(
          title: 'تقييم التطبيق',
          icon: Icons.star_border,
          onTap: _rateApp,
        ),
        SizedBox(height: 30.h),
        // Dark Mode Toggle
        const ThemeSection(),
        SizedBox(height: 30.h),
        const LanguageSection(),
        SizedBox(height: 50.h),
        CustomButton(
          text: 'تسجيل الخروج',
          onTap: () async {
            await _handleLogout(context);
          },
        ),
        SizedBox(height: 30.h),
        Text(
          'الأصدار 1.0.0',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        Text(
          'أخر تحديث : 5 سبتمبر 2025',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
