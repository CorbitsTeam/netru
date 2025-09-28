import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/send_password_reset_passcode.dart';
import '../../../domain/usecases/verify_password_reset_passcode.dart';
import '../../../domain/usecases/reset_password_with_passcode.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SendPasswordResetTokenUseCase _sendTokenUseCase;
  final VerifyPasswordResetTokenUseCase _verifyTokenUseCase;
  final ResetPasswordWithTokenUseCase _resetPasswordUseCase;

  ForgotPasswordCubit({
    required SendPasswordResetTokenUseCase sendTokenUseCase,
    required VerifyPasswordResetTokenUseCase verifyTokenUseCase,
    required ResetPasswordWithTokenUseCase resetPasswordUseCase,
  }) : _sendTokenUseCase = sendTokenUseCase,
       _verifyTokenUseCase = verifyTokenUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(ForgotPasswordInitial());

  /// Step 1: Send password reset token via email
  Future<void> sendPasswordResetToken(String email) async {
    if (email.trim().isEmpty) {
      emit(
        const ForgotPasswordFailure(
          error: 'يرجى إدخال البريد الإلكتروني',
          currentStep: PasswordResetStep.emailInput,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      emit(
        const ForgotPasswordFailure(
          error: 'عنوان البريد الإلكتروني غير صحيح',
          currentStep: PasswordResetStep.emailInput,
        ),
      );
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      final result = await _sendTokenUseCase(
        SendPasswordResetTokenParams(email: email.trim()),
      );

      result.fold(
        (failure) => emit(
          ForgotPasswordFailure(
            error: failure.message,
            currentStep: PasswordResetStep.emailInput,
          ),
        ),
        (success) => emit(
          TokenSent(
            email: email.trim(),
            message:
                'تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
          ),
        ),
      );
    } catch (e) {
      emit(
        ForgotPasswordFailure(
          error: e.toString(),
          currentStep: PasswordResetStep.emailInput,
        ),
      );
    }
  }

  /// Step 2: Verify token received via email
  Future<void> verifyToken(String email, String token) async {
    if (token.trim().isEmpty) {
      emit(
        const ForgotPasswordFailure(
          error: 'يرجى إدخال رمز التحقق',
          currentStep: PasswordResetStep.emailSent,
        ),
      );
      return;
    }

    if (token.trim().length != 6) {
      emit(
        const ForgotPasswordFailure(
          error: 'رمز التحقق يجب أن يكون 6 أرقام',
          currentStep: PasswordResetStep.emailSent,
        ),
      );
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      final result = await _verifyTokenUseCase(
        VerifyPasswordResetTokenParams(email: email, token: token.trim()),
      );

      result.fold(
        (failure) => emit(
          ForgotPasswordFailure(
            error: failure.message,
            currentStep: PasswordResetStep.emailSent,
          ),
        ),
        (success) => emit(
          TokenVerified(
            email: email,
            token: token.trim(),
            message: 'تم التحقق من الرمز بنجاح',
          ),
        ),
      );
    } catch (e) {
      emit(
        ForgotPasswordFailure(
          error: e.toString(),
          currentStep: PasswordResetStep.emailSent,
        ),
      );
    }
  }

  /// Step 3: Reset password with verified token
  Future<void> resetPasswordWithToken(
    String email,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword.trim().isEmpty) {
      emit(
        const ForgotPasswordFailure(
          error: 'يرجى إدخال كلمة المرور الجديدة',
          currentStep: PasswordResetStep.newPasswordInput,
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      emit(
        const ForgotPasswordFailure(
          error: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
          currentStep: PasswordResetStep.newPasswordInput,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      emit(
        const ForgotPasswordFailure(
          error: 'كلمات المرور غير متطابقة',
          currentStep: PasswordResetStep.newPasswordInput,
        ),
      );
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      final result = await _resetPasswordUseCase(
        ResetPasswordWithTokenParams(
          email: email,
          token: token,
          newPassword: newPassword,
        ),
      );

      result.fold(
        (failure) => emit(
          ForgotPasswordFailure(
            error: failure.message,
            currentStep: PasswordResetStep.newPasswordInput,
          ),
        ),
        (success) => emit(
          const PasswordResetSuccess(message: 'تم تغيير كلمة المرور بنجاح'),
        ),
      );
    } catch (e) {
      emit(
        ForgotPasswordFailure(
          error: e.toString(),
          currentStep: PasswordResetStep.newPasswordInput,
        ),
      );
    }
  }

  /// Reset state to initial
  void resetState() {
    emit(ForgotPasswordInitial());
  }

  /// Resend password reset token
  Future<void> resendPasswordResetToken(String email) async {
    await sendPasswordResetToken(email);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate email with detailed feedback
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    if (!_isValidEmail(value.trim())) {
      return 'عنوان البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Validate password format
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    return null;
  }

  /// Navigate back to previous step
  void goToPreviousStep(String email, {String? token}) {
    if (token != null) {
      // Go back from password input to token input
      emit(
        TokenSent(
          email: email,
          message: 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
        ),
      );
    } else {
      // Go back from token input to email input
      emit(ForgotPasswordInitial());
    }
  }

  /// Validate token format
  String? validateToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رمز التحقق مطلوب';
    }

    if (value.trim().length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// Validate password confirmation
  String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }
}
