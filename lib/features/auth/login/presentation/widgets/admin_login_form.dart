import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/user_entity.dart';
import '../cubit/login_cubit.dart';
import '../../../widgets/validated_text_form_field.dart';
import 'login_button.dart';

class AdminLoginForm extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const AdminLoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().loginUser(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
        userType: UserType.admin,
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
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل البريد الإلكتروني',
            prefixIcon: Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validationType: ValidationType.email,
            realTimeValidation: true,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.admin,
                ),
          ),
          SizedBox(height: 24.h),
          ValidatedTextFormField(
            controller: _passwordController,
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            prefixIcon: Icon(Icons.lock_outline),
            obscureText: _obscurePassword,
            validationType: ValidationType.password,
            realTimeValidation: true,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          SizedBox(height: 40.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
