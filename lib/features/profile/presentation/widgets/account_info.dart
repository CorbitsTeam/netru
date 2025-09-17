import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/features/profile/presentation/widgets/custom_account_info_row.dart';
import 'package:netru_app/features/profile/presentation/widgets/custom_button.dart';
import 'package:netru_app/features/profile/presentation/widgets/language_section.dart';
import 'package:netru_app/features/profile/presentation/widgets/theme_section.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear user data from SharedPreferences
      await UserDataHelper().clearCurrentUser();

      // Navigate to login screen
      if (context.mounted) {
        context.pushReplacementNamed(Routes.loginScreen);
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAccountInfoRow(
          title: 'المعلومات شخصيه',
          icon: Icons.person_outline,
          onTap: null,
        ),
        SizedBox(height: 30.h),
        const CustomAccountInfoRow(
          title: 'تغيير كلمة المرور',
          icon: Icons.lock_outline,
          onTap: null,
        ),
        SizedBox(height: 30.h),
        const CustomAccountInfoRow(
          title: 'تقييم التطبيق',
          icon: Icons.star_border,
          onTap: null,
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
        SizedBox(height: 10.h),
        CustomButton(
          text: 'حذف الحساب',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          borderColor: Colors.red,
          onTap: () {
            // Handle account deletion action
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
