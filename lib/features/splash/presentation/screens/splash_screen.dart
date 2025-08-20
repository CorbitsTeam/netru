import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import 'package:netru_app/core/cubit/permission/permission_cubit.dart';
import 'package:netru_app/features/splash/presentation/widgets/permission_dialog.dart';
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
    _initializeApp();
  }

  void _initializeApp() async {
    // انتظار قليل لعرض splash screen
    await Future.delayed(
        const Duration(seconds: 2));

    // التحقق من الصلاحيات باستخدام الـ PermissionCubit الموجود في البنية
    if (mounted) {
      context
          .read<PermissionCubit>()
          .checkPermissions();
    }
  }

  void _navigateToHome() {
    // استخدام النظام الموجود للتنقل
    if (mounted) {
      context.pushNamed(Routes.customBottomBar);
    }
  }

  void _showLocationPermissionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: 'صلاحية الموقع',
        description:
            'يحتاج التطبيق إلى صلاحية الوصول للموقع لتوفير خدمات محسنة وأكثر دقة.',
        icon: Icons.location_on,
        onAllow: () {
          Navigator.of(context).pop();
          context
              .read<PermissionCubit>()
              .requestPermissions();
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
      builder: (context) => LocationServiceDialog(
        onEnable: () {
          Navigator.of(context).pop();
          context
              .read<PermissionCubit>()
              .requestPermissions();
        },
        onCancel: () {
          Navigator.of(context).pop();
          _showPermissionDeniedDialog();
        },
      ),
    );
  }

  void _showAppSettingsDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppSettingsDialog(
        onOpenSettings: () {
          Navigator.of(context).pop();
          context
              .read<PermissionCubit>()
              .openSettings();
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
      builder: (context) => AlertDialog(
        title: const Text('تحذير'),
        content: const Text(
            'لن يعمل التطبيق بشكل صحيح بدون الصلاحيات المطلوبة. هل تريد المحاولة مرة أخرى؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<PermissionCubit>()
                  .retry();
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome(); // أو يمكنك منع المتابعة
            },
            child: const Text(
                'المتابعة بدون صلاحيات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PermissionCubit,
          PermissionState>(
        listener: (context, state) {
          if (state is PermissionGranted) {
            _navigateToHome();
          } else if (state is PermissionDenied) {
            _showLocationPermissionDialog();
          } else if (state is PermissionError) {
            _showLocationServiceDialog();
          }
        },
        child: BlocBuilder<PermissionCubit,
            PermissionState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // شعار التطبيق (استخدم المسار الصحيح من AppAssets)
                  Image.asset(
                    AppAssets
                        .mainLogo, // تأكد من أن هذا المسار صحيح
                    height: 180.h,
                    width: 180.w,
                    errorBuilder: (context, error,
                        stackTrace) {
                      // في حالة عدم وجود الصورة، اعرض أيقونة بديلة
                      return Container(
                        height: 180.h,
                        width: 180.w,
                        decoration: BoxDecoration(
                          color: AppColors
                              .primaryColor
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius
                                  .circular(20.r),
                        ),
                        child: Icon(
                          Icons.security,
                          size: 80.sp,
                          color: AppColors
                              .primaryColor,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 18.h),

                  // شعار التطبيق
                  Text(
                    "من أجل امن وامان مصر",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color:
                          AppColors.primaryColor,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // مؤشر التحميل أو رسالة الحالة
                  if (state
                      is PermissionLoading) ...[
                    CircularProgressIndicator(
                      color:
                          AppColors.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري التحقق من الصلاحيات...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else if (state
                      is PermissionInitial) ...[
                    CircularProgressIndicator(
                      color:
                          AppColors.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تحضير التطبيق...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
