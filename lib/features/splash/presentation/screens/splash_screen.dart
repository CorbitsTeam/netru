import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/extensions/navigation_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      context.pushNamed(Routes.customBottomBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.mainLogo,
                height: 180.h, width: 180.w),
            SizedBox(height: 18.h),
            Text(
              "من أجل امن وامان مصر",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp),
            ),
          ],
        ),
      ),
    );
  }
}
