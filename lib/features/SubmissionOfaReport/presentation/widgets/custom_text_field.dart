import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
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
  final bool isPassword;
  final void Function(String)? onChanged;
  final bool enabled;

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
    this.isPassword = false,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState
    extends State<CustomTextField> {
  bool _isPasswordVisible = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create label text with required indicator
    String labelText = widget.label;
    if (widget.isRequired) {
      labelText += ' *';
    }

    // Determine if text should be obscured
    bool shouldObscureText =
        widget.isPassword
            ? !_isPasswordVisible
            : widget.obscureText;

    // Determine suffix icon
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility
              : Icons.visibility_off,
          color: Colors.grey[600],
          size: 20.sp,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible =
                !_isPasswordVisible;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator:
          widget.isRequired
              ? widget.validator
              : null,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      textAlign: widget.textAlign,
      obscureText: shouldObscureText,
      maxLength:
          widget.showCounter
              ? widget.maxLength
              : null,
      buildCounter:
          widget.showCounter
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
            widget.hintText ??
            (widget.readOnly
                ? 'اضغط للاختيار'
                : null),
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 12.sp,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: widget.prefixIcon,
        filled: true,
        fillColor: Colors.grey[100],

        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          borderSide: const BorderSide(
            color: Color(0xFF1E3A8A),
          ),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical:
              widget.maxLines > 1 ? 12.h : 10.h,
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
