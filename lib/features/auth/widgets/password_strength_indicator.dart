import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/auth_validation_utils.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showStrengthText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showStrengthText = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = AuthValidationUtils.getPasswordStrength(password);
    final strengthText = AuthValidationUtils.getPasswordStrengthText(strength);

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength indicator bars
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.only(right: index < 4 ? 4.w : 0),
                  decoration: BoxDecoration(
                    color:
                        index < strength
                            ? _getStrengthColor(strength)
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),

          if (showStrengthText && password.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'قوة كلمة المرور: $strengthText',
              style: TextStyle(
                fontSize: 12.sp,
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (password.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildRequirementsList(),
          ],
        ],
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
      case 5:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  Widget _buildRequirementsList() {
    final requirements = [
      {'text': '8 أحرف على الأقل', 'isValid': password.length >= 8},
      {
        'text': 'حرف كبير واحد على الأقل',
        'isValid': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'text': 'حرف صغير واحد على الأقل',
        'isValid': RegExp(r'[a-z]').hasMatch(password),
      },
      {
        'text': 'رقم واحد على الأقل',
        'isValid': RegExp(r'[0-9]').hasMatch(password),
      },
      {
        'text': 'رمز خاص واحد على الأقل',
        'isValid': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          requirements.map((req) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Icon(
                    req['isValid'] as bool
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 16.sp,
                    color:
                        req['isValid'] as bool
                            ? AppColors.success
                            : Colors.grey.shade400,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    req['text'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          req['isValid'] as bool
                              ? AppColors.success
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
