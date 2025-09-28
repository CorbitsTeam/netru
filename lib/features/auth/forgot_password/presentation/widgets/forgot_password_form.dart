import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../widgets/validated_text_form_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'reset_password_button.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordCubit>().sendPasswordResetToken(
        _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          // Clear the form on success
          _emailController.clear();
          _focusNode.unfocus();
        }
      },
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        delay: const Duration(milliseconds: 400),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // Email Input Field
              ValidatedTextFormField(
                controller: _emailController,
                focusNode: _focusNode,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined, size: 20.sp),
                keyboardType: TextInputType.emailAddress,
                validationType: ValidationType.email,
                realTimeValidation: true,
                showValidationIcon: true,
                validator:
                    (value) => context
                        .read<ForgotPasswordCubit>()
                        .validateEmail(value),
              ),

              SizedBox(height: 32.h),

              // Submit Button
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  final isLoading = state is ForgotPasswordLoading;
                  return ResetPasswordButton(
                    onPressed: _handleSubmit,
                    isLoading: isLoading,
                    text: 'إرسال رابط إعادة التعيين',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
