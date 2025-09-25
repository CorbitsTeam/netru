import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/app_assets.dart';

class LoginHeader extends StatelessWidget {
  final VoidCallback? onLogoDoubleTap;

  const LoginHeader({super.key, this.onLogoDoubleTap});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          // اللوغو بدون إطار - واضح وبسيط
          GestureDetector(
            onDoubleTap: onLogoDoubleTap,
            child: SvgPicture.asset(
              AppAssets.mainLogoSvg,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 32.h),

          // النص الترحيبي
          Text(
            'أهلاً وسهلاً',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a1a),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'سجل دخولك للمتابعة',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF6B7280),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
