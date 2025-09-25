import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/user_entity.dart';
import '../cubit/login_cubit.dart';
import 'login_text_field.dart';
import 'login_password_field.dart';
import 'login_button.dart';

class ForeignerLoginForm extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const ForeignerLoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ForeignerLoginForm> createState() => _ForeignerLoginFormState();
}

class _ForeignerLoginFormState extends State<ForeignerLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passportController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passportController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().loginUser(
        identifier: _passportController.text.trim(),
        password: _passwordController.text,
        userType: UserType.foreigner,
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
            controller: _passportController,
            label: 'رقم جواز السفر',
            hint: 'أدخل رقم جواز السفر',
            icon: Icons.flight_outlined,
            keyboardType: TextInputType.text,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.foreigner,
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
          SizedBox(height: 20.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
