import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../widgets/validated_text_form_field.dart';
import '../cubit/login_cubit.dart';
import 'login_button.dart';

class CitizenLoginForm extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const CitizenLoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<CitizenLoginForm> createState() => _CitizenLoginFormState();
}

class _CitizenLoginFormState extends State<CitizenLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().loginUser(
        identifier: _nationalIdController.text.trim(),
        password: _passwordController.text,
        userType: UserType.citizen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 32.h),
          ValidatedTextFormField(
            controller: _nationalIdController,
            label: 'الرقم القومي',
            hint: 'أدخل الرقم القومي (14 رقم)',
            prefixIcon: Icon(Icons.person_outline, size: 20.sp),
            keyboardType: TextInputType.number,
            validationType: ValidationType.nationalId,
            realTimeValidation: true,
            showValidationIcon: true,
          ),
          SizedBox(height: 10.h),
          ValidatedTextFormField(
            controller: _passwordController,
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20.sp,
              ),
            ),
            validationType: ValidationType.required,
            realTimeValidation: true,
            showValidationIcon: true,
          ),
          SizedBox(height: 16.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgotPasswordEmail');
              },
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF002768), // Primary color
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
