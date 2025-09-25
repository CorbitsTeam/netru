import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../widgets/validated_text_form_field.dart';

/// Widget لعرض رسائل التحقق والأخطاء
class ValidationMessageWidget extends StatelessWidget {
  final String? message;
  final bool isError;
  final bool isLoading;

  const ValidationMessageWidget({
    super.key,
    this.message,
    this.isError = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null && !isLoading) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:
            isLoading
                ? AppColors.primaryColor.withOpacity(0.1)
                : isError
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              isLoading
                  ? AppColors.primaryColor
                  : isError
                  ? Colors.red
                  : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            )
          else
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
              size: 16.sp,
            ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isLoading ? 'جاري التحقق...' : message!,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    isLoading
                        ? AppColors.primaryColor
                        : isError
                        ? Colors.red
                        : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget محدث للحقول النصية مع التحقق المباشر
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final bool isRequired;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Future<void> Function(String)? onRealTimeValidation;
  final String? validationMessage;
  final bool hasValidationError;
  final bool isValidating;

  const ValidatedTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onRealTimeValidation,
    this.validationMessage,
    this.hasValidationError = false,
    this.isValidating = false,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: (value) {
            widget.onChanged?.call(value);

            // تأخير التحقق المباشر لتجنب الكثرة في الطلبات
            if (widget.onRealTimeValidation != null && value.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_controller.text == value) {
                  widget.onRealTimeValidation!(value);
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'أدخل ${widget.label}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            suffixIcon:
                widget.isValidating
                    ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                    : widget.validationMessage != null
                    ? Icon(
                      widget.hasValidationError
                          ? Icons.error
                          : Icons.check_circle,
                      color:
                          widget.hasValidationError ? Colors.red : Colors.green,
                      size: 20.sp,
                    )
                    : null,
          ),
        ),
        ValidationMessageWidget(
          message: widget.validationMessage,
          isError: widget.hasValidationError,
          isLoading: widget.isValidating,
        ),
      ],
    );
  }
}
