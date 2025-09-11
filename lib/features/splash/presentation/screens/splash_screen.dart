import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/cubit/permission/permission_cubit.dart';
import 'package:netru_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:netru_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:netru_app/features/splash/presentation/widgets/permission_dialog.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // انتظار قليل لعرض splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Check authentication status first
    if (mounted) {
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  void _navigateToHome() {
    // استخدام النظام الموجود للتنقل
    if (mounted) {
      context.pushNamed(Routes.customBottomBar);
    }
  }

  void _navigateToLogin() {
    // Navigate to login page
    if (mounted) {
      context.pushNamed(Routes.loginScreen);
    }
  }

  void _showLocationPermissionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PermissionDialog(
            title: 'صلاحية الموقع مطلوبة',
            description:
                'تطبيق نترو يحتاج إلى معرفة موقعك لتوفير خدمات الأمان التالية:\n\n🚨 الإبلاغ الفوري عن الحوادث\n🚔 تحديد أقرب نقطة شرطة\n📱 خدمات الطوارئ السريعة\n🗺️ خرائط الأمان المحلية\n\nصلاحية الموقع ضرورية لحمايتك وحماية مجتمعك.',
            icon: Icons.my_location,
            onAllow: () {
              Navigator.of(context).pop();
              context.read<PermissionCubit>().requestLocationPermission();
            },
            onDeny: () {
              Navigator.of(context).pop();
              _showPermissionDeniedDialog();
            },
          ),
    );
  }

  void _showLocationServiceDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => LocationServiceDialog(
            onEnable: () {
              Navigator.of(context).pop();
              context.read<PermissionCubit>().requestLocationPermission();
            },
            onCancel: () {
              Navigator.of(context).pop();
              _showPermissionDeniedDialog();
            },
          ),
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 24.sp),
                SizedBox(width: 8.w),
                const Text('تحذير أمني'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بدون صلاحية الموقع، لن يتمكن تطبيق نترو من:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                const Text('• تحديد موقعك في حالات الطوارئ'),
                const Text('• إرسال التقارير الأمنية بدقة'),
                const Text('• توفير خدمات الأمان المحلية'),
                SizedBox(height: 12.h),
                const Text(
                  'هل تريد المحاولة مرة أخرى لضمان حمايتك؟',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToHome();
                },
                child: Text(
                  'المتابعة بمخاطر محدودة',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<PermissionCubit>().requestLocationPermission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // User is logged in, check permissions then navigate to home
                context.read<PermissionCubit>().requestLocationPermission();
              } else if (state is AuthUnauthenticated) {
                // User is not logged in, navigate to login
                _navigateToLogin();
              }
            },
          ),
          BlocListener<PermissionCubit, PermissionState>(
            listener: (context, state) {
              if (state is PermissionGranted) {
                _navigateToHome();
              } else if (state is PermissionDenied) {
                _showLocationPermissionDialog();
              } else if (state is PermissionError) {
                _showLocationServiceDialog();
              }
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // الجزء العلوي - شعار وزارة الداخلية
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // شعار وزارة الداخلية مع تصميم محسن
                      Container(
                        width: 140.w,
                        height: 140.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.95),
                              Colors.grey[50]!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circle border effect
                            Container(
                              width: 130.w,
                              height: 130.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Logo content
                            Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.security,
                                size: 50.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // اسم التطبيق مع تأثيرات جميلة
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          "نترو",
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // وصف التطبيق
                      Text(
                        "تطبيق أمني متقدم",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // الجزء الأوسط - رسالة الأمان
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                "من أجل أمن وأمان جمهورية مصر العربية",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // الجزء السفلي - مؤشر التحميل
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<PermissionCubit, PermissionState>(
                      builder: (context, state) {
                        if (state is PermissionLoading ||
                            state is PermissionInitial) {
                          return Column(
                            children: [
                              SizedBox(
                                width: 40.w,
                                height: 40.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state is PermissionLoading
                                    ? 'جاري التحقق من الصلاحيات...'
                                    : 'جاري تحضير التطبيق...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 40.h),

                    // شعار وزارة الداخلية صغير
                    Text(
                      "وزارة الداخلية - جمهورية مصر العربية",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
