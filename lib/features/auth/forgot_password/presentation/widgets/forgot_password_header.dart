import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/app_assets.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          // اللوغو
          SvgPicture.asset(
            AppAssets.mainLogoSvg,
            width: 100.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 32.h),

          // النص الرئيسي
          Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a1a),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // النص الوصفي
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
                fontFamily: 'Almarai',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
