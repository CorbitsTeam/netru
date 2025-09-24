import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';

class LoginBottomSection extends StatelessWidget {
  final VoidCallback onSignupTap;

  const LoginBottomSection({super.key, required this.onSignupTap});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ليس لديك حساب؟ ',
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 14.sp,
              fontFamily: 'Almarai',
            ),
          ),
          GestureDetector(
            onTap: onSignupTap,
            child: Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
