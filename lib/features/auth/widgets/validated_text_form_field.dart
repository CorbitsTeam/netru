import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ValidatedTextFormField
    extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final ValidationType validationType;
  final bool showValidationIcon;
  final bool realTimeValidation;
  final String? errorText;
  final String? successText;

  const ValidatedTextFormField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization =
        TextCapitalization.none,
    this.validationType = ValidationType.none,
    this.showValidationIcon = true,
    this.realTimeValidation = true,
    this.errorText,
    this.successText,
  });

  @override
  State<ValidatedTextFormField> createState() =>
      _ValidatedTextFormFieldState();
}

class _ValidatedTextFormFieldState
    extends State<ValidatedTextFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  String? _currentError;
  bool _isValid = false;
  bool _showValidation = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(_animationController);

    widget.focusNode?.addListener(
      _handleFocusChange,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.focusNode?.removeListener(
      _handleFocusChange,
    );
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused =
          widget.focusNode?.hasFocus ?? false;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _validateInput(String value) {
    if (!widget.realTimeValidation) return;

    setState(() {
      _showValidation = value.isNotEmpty;
      if (_showValidation) {
        _currentError = _getValidationError(
          value,
        );
        _isValid = _currentError == null;
      } else {
        _currentError = null;
        _isValid = false;
      }
    });
  }

  String? _getValidationError(String value) {
    // Custom validator first
    if (widget.validator != null) {
      final customError = widget.validator!(
        value,
      );
      if (customError != null) return customError;
    }

    // Built-in validation based on type
    switch (widget.validationType) {
      case ValidationType.email:
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value)) {
          return 'عنوان البريد الإلكتروني غير صحيح';
        }
        break;

      case ValidationType.password:
        if (value.length < 8) {
          return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
        }
        if (!RegExp(
          r'^(?=.*[a-zA-Z])(?=.*\d)',
        ).hasMatch(value)) {
          return 'يجب أن تحتوي على حروف وأرقام';
        }
        break;

      case ValidationType.phone:
        final cleanPhone = value.replaceAll(
          RegExp(r'[\s-]'),
          '',
        );
        if (!RegExp(
          r'^\+?[0-9]{10,15}$',
        ).hasMatch(cleanPhone)) {
          return 'رقم الهاتف غير صحيح';
        }
        break;

      case ValidationType.nationalId:
        if (!RegExp(
          r'^[0-9]{14}$',
        ).hasMatch(value)) {
          return 'الرقم القومي يجب أن يكون 14 رقم';
        }
        break;

      case ValidationType.name:
        if (value.trim().length < 2) {
          return 'الاسم قصير جداً';
        }
        if (!RegExp(
          r'^[\u0600-\u06FF\s]+$',
        ).hasMatch(value)) {
          return 'الاسم يجب أن يكون باللغة العربية فقط';
        }
        break;

      case ValidationType.required:
        if (value.trim().isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        break;

      case ValidationType.none:
        break;
    }

    return null;
  }

  Widget? _buildValidationIcon() {
    if (!widget.showValidationIcon ||
        !_showValidation)
      return null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      child: Icon(
        _isValid
            ? Icons.check_circle
            : Icons.error,
        color:
            _isValid ? Colors.green : Colors.red,
        size: 20.sp,
      ),
      builder:
          (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],

        // Text Field
        AnimatedBuilder(
          animation: _colorAnimation,
          builder:
              (context, child) => TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                inputFormatters:
                    widget.inputFormatters,
                textCapitalization:
                    widget.textCapitalization,
                onChanged: (value) {
                  _validateInput(value);
                  widget.onChanged?.call(value);
                },
                onSaved: widget.onSaved,
                onTap: widget.onTap,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontFamily: 'Almarai',
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary
                        .withOpacity(0.6),
                    fontFamily: 'Almarai',
                  ),
                  prefixIcon:
                      widget.prefixIcon != null
                          ? Padding(
                            padding:
                                EdgeInsets.symmetric(
                                  horizontal:
                                      12.w,
                                ),
                            child:
                                widget.prefixIcon,
                          )
                          : null,
                  suffixIcon:
                      _buildValidationIcon() ??
                      widget.suffixIcon,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                    borderSide: BorderSide(
                      color:
                          _showValidation
                              ? (_isValid
                                  ? Colors.green
                                      .withOpacity(
                                        0.5,
                                      )
                                  : Colors.red
                                      .withOpacity(
                                        0.5,
                                      ))
                              : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                        borderSide: BorderSide(
                          color:
                              _colorAnimation
                                  .value ??
                              AppColors.primary,
                          width: 2,
                        ),
                      ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder:
                      OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                        borderSide:
                            const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                      ),
                  contentPadding:
                      EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 6.h,
                      ),
                  counterText:
                      '', // Hide character counter
                ),
                validator:
                    widget.realTimeValidation
                        ? null
                        : widget.validator,
              ),
        ),

        // Validation Message
        AnimatedContainer(
          duration: const Duration(
            milliseconds: 300,
          ),
          height:
              (_currentError != null ||
                      widget.errorText != null ||
                      (_isValid &&
                          widget.successText !=
                              null))
                  ? null
                  : 0,
          child: AnimatedOpacity(
            duration: const Duration(
              milliseconds: 300,
            ),
            opacity:
                (_currentError != null ||
                        widget.errorText !=
                            null ||
                        (_isValid &&
                            widget.successText !=
                                null))
                    ? 1.0
                    : 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                top: 6.h,
                right: 4.w,
              ),
              child: Row(
                children: [
                  Icon(
                    (_currentError != null ||
                            widget.errorText !=
                                null)
                        ? Icons.error_outline
                        : Icons
                            .check_circle_outline,
                    size: 14.sp,
                    color:
                        (_currentError != null ||
                                widget.errorText !=
                                    null)
                            ? Colors.red[600]
                            : Colors.green[600],
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      widget.errorText ??
                          _currentError ??
                          widget.successText ??
                          '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                            (_currentError !=
                                        null ||
                                    widget.errorText !=
                                        null)
                                ? Colors.red[600]
                                : Colors
                                    .green[600],
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum ValidationType {
  none,
  email,
  password,
  phone,
  nationalId,
  name,
  required,
}

// Password strength widget
class PasswordStrengthIndicator
    extends StatelessWidget {
  final String password;
  final bool show;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.show = true,
  });

  PasswordStrength _getPasswordStrength(
    String password,
  ) {
    if (password.isEmpty)
      return PasswordStrength.none;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password))
      score++;
    if (RegExp(r'[A-Z]').hasMatch(password))
      score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password))
      score++;

    if (score < 2) return PasswordStrength.weak;
    if (score < 4) return PasswordStrength.medium;
    if (score < 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  @override
  Widget build(BuildContext context) {
    if (!show || password.isEmpty)
      return const SizedBox.shrink();

    final strength = _getPasswordStrength(
      password,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'قوة كلمة المرور: ',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Almarai',
                ),
              ),
              Text(
                strength.text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: strength.color,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index < 3 ? 4.w : 0,
                  ),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color:
                        index < strength.level
                            ? strength.color
                            : Colors.grey[300],
                    borderRadius:
                        BorderRadius.circular(
                          2.r,
                        ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum PasswordStrength {
  none(0, 'ضعيفة جداً', Colors.grey),
  weak(1, 'ضعيفة', Colors.red),
  medium(2, 'متوسطة', Colors.orange),
  strong(3, 'قوية', Colors.blue),
  veryStrong(4, 'قوية جداً', Colors.green);

  const PasswordStrength(
    this.level,
    this.text,
    this.color,
  );

  final int level;
  final String text;
  final Color color;
}
