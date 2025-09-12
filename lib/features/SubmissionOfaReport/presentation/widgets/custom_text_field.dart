import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool isRequired;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextAlign textAlign;
  final int? maxLength;
  final bool showCounter;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.isRequired = true,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.textAlign = TextAlign.justify,
    this.maxLength,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    // Create label text with required indicator
    String labelText = label;
    if (isRequired) {
      labelText += ' *';
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: isRequired ? validator : null,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: textAlign,
      obscureText: obscureText,
      maxLength: showCounter ? maxLength : null,
      buildCounter:
          showCounter
              ? null
              : (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.primaryColor,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: const Color(0xFF1E3A8A),
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        hintText:
            hintText ??
            (readOnly ? 'اضغط للاختيار' : null),
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 12.sp,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.grey[100],

        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Color(0xFF1E3A8A),
          ),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: maxLines > 1 ? 12.h : 10.h,
        ),

        // Error style
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

// Custom Dropdown Field
class CustomDropdownField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> items;
  final String? Function(String?)? validator;
  final bool isRequired;
  final String? hintText;

  const CustomDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.items,
    this.validator,
    this.isRequired = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value:
          controller.text.isEmpty
              ? null
              : controller.text,
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
      validator: isRequired ? validator : null,
      decoration: InputDecoration(
        hintText: hintText ?? 'اختر من القائمة',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 10.sp,
        ),
        filled: true,
        fillColor: Colors.grey[100],

        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Color(0xFF1E3A8A),
          ),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
        ),

        // Error style
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 10.sp,
        ),
      ),

      // Dropdown items
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            );
          }).toList(),

      isExpanded: true,
      menuMaxHeight: 300,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
    );
  }
}
