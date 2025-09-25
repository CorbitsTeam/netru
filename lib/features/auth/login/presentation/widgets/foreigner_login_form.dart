import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/user_entity.dart';
import '../cubit/login_cubit.dart';
import '../../../widgets/validated_text_form_field.dart';
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
          ValidatedTextFormField(
            controller: _passportController,
            label: 'رقم جواز السفر',
            hint: 'أدخل رقم جواز السفر',
            prefixIcon: Icon(Icons.flight_outlined),
            keyboardType: TextInputType.text,
            validationType: ValidationType.required,
            realTimeValidation: true,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.foreigner,
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
          SizedBox(height: 20.h),
          LoginButton(onPressed: _handleSubmit, isLoading: widget.isLoading),
        ],
      ),
    );
  }
}
