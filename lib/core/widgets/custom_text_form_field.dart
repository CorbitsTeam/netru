import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' as services;
import 'package:netru_app/core/extensions/theme_extensions.dart';

import '../extensions/sizedbox_extensions.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool? isAccount;
  final bool isPhoneNumber;
  final bool showAlwaysFlagAndCode;
  final FormFieldValidator<String>? validator;
  final IconData? icon;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.icon,
    this.onChanged,
    this.isAccount,
    this.isPhoneNumber = false,
    this.showAlwaysFlagAndCode = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  static final RegExp _saudiMobileRegex = RegExp(r'^\+9665\d{8}$');
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String? liveHint;

  bool _isValidEmail(String val) => _emailRegex.hasMatch(val);
  bool _isValidSaudiNumber(String val) => _saudiMobileRegex.hasMatch(val);
  bool _looksLikeEmail(String val) =>
      val.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(val);

  void _handleChange(String value) {
    String newValue = value;
    final looksLikeEmail = _looksLikeEmail(value);

    if (widget.isPhoneNumber && looksLikeEmail) {
      newValue = value.replaceAll('+966', '').replaceAll('+', '');

      if (newValue != value) {
        widget.controller.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }

      liveHint = !_isValidEmail(newValue) ? "invalid_email".tr() : null;
    } else if (widget.isPhoneNumber && !looksLikeEmail) {
      String cleaned = value;

      if (cleaned.startsWith('966')) {
        cleaned = cleaned.substring(3);
      }

      cleaned = cleaned
          .replaceAll(RegExp(r'^\+966+'), '')
          .replaceAll('+966', '');

      if (cleaned.isEmpty) {
        newValue = '';
      } else {
        newValue = '+966$cleaned';
      }

      if (newValue != value) {
        widget.controller.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }

      if (newValue.isEmpty) {
        liveHint = null;
      } else {
        final withoutPrefix = newValue.replaceFirst('+966', '');
        if (withoutPrefix.length < 9) {
          liveHint = "remaining_digits".tr(
            namedArgs: {'count': (9 - withoutPrefix.length).toString()},
          );
        } else if (!_isValidSaudiNumber(newValue)) {
          liveHint = "invalid_phone".tr();
        } else {
          liveHint = null;
        }
      }
    }

    setState(() {});
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowFlagAndCode =
        widget.isPhoneNumber &&
        (widget.showAlwaysFlagAndCode ||
            (widget.controller.text.startsWith('+966') &&
                !_looksLikeEmail(widget.controller.text)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label!,
                style:
                    widget.isAccount == true
                        ? context.textTheme.displayLarge?.copyWith(
                          fontSize: 14.sp,
                          color: context.theme.primaryColor,
                        )
                        : const TextStyle(fontWeight: FontWeight.bold),
              ),
              verticalSpace(16),
            ],
          ),
        Directionality(
          textDirection: services.TextDirection.ltr,
          child: Focus(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus(); // ⬅️ يخفي الكيبورد عند الضغط
              },
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                style: context.textTheme.displaySmall!.copyWith(
                  fontSize: 16.sp,
                ),
                onChanged: _handleChange,
                validator:
                    widget.validator ??
                    (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'field_required'.tr();
                      }
                      if (widget.isPhoneNumber) {
                        String standardizedVal = val;
                        if (standardizedVal.startsWith('966') &&
                            !standardizedVal.startsWith('+966')) {
                          standardizedVal = '+$standardizedVal';
                        }

                        if (!_isValidSaudiNumber(standardizedVal) &&
                            !_isValidEmail(val)) {
                          return 'invalid_phone_or_email'.tr();
                        }
                      }
                      return null;
                    },
                decoration: InputDecoration(
                  hintText: widget.hint,
                  filled: true,
                  fillColor: context.colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  prefixIcon:
                      shouldShowFlagAndCode
                          ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇸🇦', style: TextStyle(fontSize: 20.sp)),
                                horizontalSpace(4),
                                Text('+966', style: TextStyle(fontSize: 14.sp)),
                                horizontalSpace(8),
                              ],
                            ),
                          )
                          : (widget.icon != null
                              ? Icon(widget.icon, color: Colors.grey)
                              : null),
                  suffixText: liveHint,
                  suffixStyle: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
