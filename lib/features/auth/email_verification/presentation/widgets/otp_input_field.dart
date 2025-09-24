import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class OTPInputField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String) onChanged;
  final Function(String) onCompleted;
  final bool hasError;

  const OTPInputField({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onCompleted,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) => _buildOTPBox(index)),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 45.w,
      height: 55.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              hasError
                  ? Colors.red
                  : controllers[index].text.isNotEmpty
                  ? AppColors.primary
                  : const Color(0xFFE5E7EB),
          width: hasError || controllers[index].text.isNotEmpty ? 2 : 1,
        ),
        color:
            controllers[index].text.isNotEmpty
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
      ),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              focusNodes[index + 1].requestFocus();
            } else {
              focusNodes[index].unfocus();
            }
          } else {
            // Move to previous field
            if (index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          }

          onChanged(_getOTPCode());

          // Check if all fields are filled
          if (_getOTPCode().length == 6) {
            onCompleted(_getOTPCode());
          }
        },
      ),
    );
  }

  String _getOTPCode() {
    return controllers.map((controller) => controller.text).join();
  }
}
