import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final Duration animationDuration;
  final String? errorText;
  final bool showError;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.isRequired = false,
    this.animationDuration = const Duration(
      milliseconds: 300,
    ),
    this.errorText,
    this.showError = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.initialValue,
    this.contentPadding,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.borderRadius = 12.0,
  });

  @override
  State<CustomTextField> createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState
    extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isValid = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Validate initial value if provided
    if (widget.initialValue != null &&
        widget.initialValue!.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
            _validate(widget.initialValue);
          });
    }
  }

  @override
  void didUpdateWidget(
    CustomTextField oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorMessage = widget.errorText;
        _isValid =
            _errorMessage == null ||
            _errorMessage!.isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    // Validate when losing focus
    if (!_focusNode.hasFocus &&
        widget.controller != null) {
      _validate(widget.controller!.text);
    }
  }

  void _validate(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorMessage = error;
        _isValid = error == null;
      });
    } else if (widget.isRequired &&
        (value == null || value.isEmpty)) {
      setState(() {
        _errorMessage = 'This field is required';
        _isValid = false;
      });
    } else {
      setState(() {
        _errorMessage = null;
        _isValid = true;
      });
    }
  }

  void _handleOnChanged(String value) {
    // Real-time validation while typing
    if (_focusNode.hasFocus) {
      _validate(value);
    }

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError =
        _errorMessage != null &&
        _errorMessage!.isNotEmpty;
    final effectiveErrorText =
        widget.errorText ?? _errorMessage;
    final showError =
        (hasError ||
            effectiveErrorText != null) &&
        widget.showError;

    return FadeInUp(
      duration: widget.animationDuration,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: 8.h,
              ),
              child: Row(
                children: [
                  Text(
                    widget.label!,
                    style: theme
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w500,
                          color:
                              hasError
                                  ? widget.errorBorderColor ??
                                      AppColors
                                          .error
                                  : theme
                                      .colorScheme
                                      .onSurface,
                        ),
                  ),
                  if (widget.isRequired)
                    Text(
                      ' *',
                      style: theme
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            color:
                                AppColors.error,
                            fontWeight:
                                FontWeight.w500,
                          ),
                    ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.borderRadius.r,
              ),
              boxShadow:
                  _isFocused && _isValid
                      ? [
                        BoxShadow(
                          color: (widget
                                      .focusedBorderColor ??
                                  AppColors
                                      .surface)
                              .withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(
                            0,
                            2,
                          ),
                        ),
                      ]
                      : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              validator: widget.validator,
              onChanged: _handleOnChanged,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              inputFormatters:
                  widget.inputFormatters,
              textInputAction:
                  widget.textInputAction,
              onFieldSubmitted:
                  widget.onFieldSubmitted,
              autofocus: widget.autofocus,
              initialValue: widget.initialValue,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(
                    color:
                        widget.readOnly
                            ? theme
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)
                            : theme
                                .colorScheme
                                .onSurface,
                  ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                prefixIcon:
                    widget.prefixIcon != null
                        ? Padding(
                          padding: EdgeInsets.all(
                            2.w,
                          ),
                          child:
                              widget.prefixIcon,
                        )
                        : null,
                suffixIcon:
                    widget.suffixIcon != null
                        ? Padding(
                          padding: EdgeInsets.all(
                            2.w,
                          ),
                          child:
                              widget.suffixIcon,
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                        widget.borderRadius.r,
                      ),
                  borderSide: BorderSide(
                    color:
                        widget
                            .enabledBorderColor ??
                        AppColors.border,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                        widget.borderRadius.r,
                      ),
                  borderSide: BorderSide(
                    color:
                        hasError
                            ? widget.errorBorderColor ??
                                AppColors.error
                            : widget.enabledBorderColor ??
                                AppColors.border,
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                        widget.borderRadius.r,
                      ),
                  borderSide: BorderSide(
                    color:
                        hasError
                            ? widget.errorBorderColor ??
                                AppColors.error
                            : widget.focusedBorderColor ??
                                AppColors.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                        widget.borderRadius.r,
                      ),
                  borderSide: BorderSide(
                    color:
                        widget.errorBorderColor ??
                        AppColors.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder:
                    OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                            widget.borderRadius.r,
                          ),
                      borderSide: BorderSide(
                        color:
                            widget
                                .errorBorderColor ??
                            AppColors.error,
                        width: 1.5,
                      ),
                    ),
                filled: true,
                fillColor:
                    widget.readOnly
                        ? AppColors.background
                            .withOpacity(0.5)
                        : AppColors.surface,
                contentPadding:
                    widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                counterText: '',
                errorStyle: const TextStyle(
                  height: 0,
                  fontSize: 0,
                ),
              ),
            ),
          ),
          if (showError)
            FadeIn(
              duration: widget.animationDuration,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 6.h,
                  left: 4.w,
                ),
                child: Text(
                  effectiveErrorText!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color:
                            widget
                                .errorBorderColor ??
                            AppColors.error,
                        fontSize: 12.sp,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
