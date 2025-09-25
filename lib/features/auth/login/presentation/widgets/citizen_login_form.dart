import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/user_entity.dart';
import '../cubit/login_cubit.dart';
import 'login_text_field.dart';
import 'login_password_field.dart';
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
          LoginTextField(
            controller: _nationalIdController,
            label: 'الرقم القومي',
            hint: 'أدخل الرقم القومي (14 رقم)',
            icon: Icons.person_outline,
            keyboardType: TextInputType.number,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.citizen,
                ),
          ),
          SizedBox(height: 18.h),
          LoginPasswordField(
            controller: _passwordController,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            obscureText: _obscurePassword,
            onToggleVisibility:
                () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          SizedBox(height: 20.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
