import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_cubit.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_state.dart';
import 'package:netru_app/features/auth/widgets/animated_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/services/location_service.dart';

class ProfileReviewStep extends StatelessWidget {
  final Map<String, String> userData;
  final GovernorateModel? selectedGovernorate;
  final CityModel? selectedCity;
  final String email;

  const ProfileReviewStep({
    super.key,
    required this.userData,
    this.selectedGovernorate,
    this.selectedCity,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          'مراجعة البيانات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 20.h),

        _buildReviewSection('البيانات الشخصية', Icons.person, [
          if (userData['fullName'] != null)
            _buildReviewItem('الاسم الكامل', userData['fullName']!),
          if (userData['nationalId'] != null)
            _buildReviewItem('الرقم القومي', userData['nationalId']!),
          if (userData['passportNumber'] != null)
            _buildReviewItem('رقم جواز السفر', userData['passportNumber']!),
          if (userData['phone'] != null)
            _buildReviewItem('رقم الهاتف', userData['phone']!),
        ]),

        SizedBox(height: 20.h),

        _buildReviewSection('العنوان', Icons.location_on, [
          if (selectedGovernorate != null)
            _buildReviewItem('المحافظة', selectedGovernorate!.name),
          if (selectedCity != null)
            _buildReviewItem('المدينة', selectedCity!.name),
        ]),

        SizedBox(height: 40.h),

        BlocBuilder<SignupCubit, SignupState>(
          builder: (context, state) {
            return AnimatedButton(
              text: 'إكمال التسجيل',
              onPressed: () {
                final currentUser = Supabase.instance.client.auth.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خطأ: لا يوجد مستخدم مصدق')),
                  );
                  return;
                }

                final userModel = {
                  'id': currentUser.id,
                  'email': email,
                  ...userData,
                };

                // Use cubit to complete profile (expecting UserModel in original code)
                context.read<SignupCubit>().registerUser(userModel);
              },
              isLoading: state is SignupLoading,
              backgroundColor: AppColors.primary,
              width: double.infinity,
              height: 50.h,
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, IconData icon, List<Widget> items) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
