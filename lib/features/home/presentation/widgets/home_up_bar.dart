import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeUpBar extends StatelessWidget {
  const HomeUpBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          // Navigate to login page when user logs out
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppAssets.imageProfile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 1.w,
                      height: 28.h,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserName(state),
                          style: TextStyle(fontSize: 11.sp),
                        ),
                        Text(
                          _getUserLocation(state),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                Text(
                  "home".tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(flex: 2),
                IconButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: Icon(
                    Icons.logout,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getUserName(AuthState state) {
    if (state is AuthLoggedIn) {
      return state.user.fullName;
    }
    return "مستخدم";
  }

  String _getUserLocation(AuthState state) {
    if (state is AuthLoggedIn) {
      return state.user.governorateName ?? state.user.cityName ?? "غير محدد";
    }
    return "غير محدد";
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("تسجيل الخروج"),
            content: const Text("هل أنت متأكد من تسجيل الخروج؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<AuthCubit>().logout();
                },
                child: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
