import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/login_user_entity.dart';
import '../cubit/login_cubit.dart';
import 'login_text_field.dart';
import 'login_password_field.dart';
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
          LoginTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.admin,
                ),
          ),
          SizedBox(height: 24.h),
          LoginPasswordField(
            controller: _passwordController,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            obscureText: _obscurePassword,
            onToggleVisibility:
                () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          SizedBox(height: 40.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
