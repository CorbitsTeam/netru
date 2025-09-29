import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SupabaseClient _supabaseClient;

  ForgotPasswordCubit({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client,
      super(ForgotPasswordInitial());

  /// Send OTP to user's email
  Future<void> sendOtp(String email) async {
    try {
      // Validate email format
      final emailError = _validateEmail(email);
      if (emailError != null) {
        emit(
          ForgotPasswordValidationError(fieldName: 'email', error: emailError),
        );
        return;
      }

      emit(ForgotPasswordLoading());

      log('🔄 إرسال OTP إلى الإيميل: $email');

      // Check if email exists in users table first
      final userExists = await _checkEmailExistsInUsersTable(email);
      if (!userExists) {
        emit(
          const ForgotPasswordFailure(
            error: 'البريد الإلكتروني غير موجود في النظام',
          ),
        );
        return;
      }

      // Send OTP using Supabase Auth
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );

      log('✅ تم إرسال OTP بنجاح');

      emit(
        ForgotPasswordOtpSent(
          email: email,
          message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
        ),
      );
    } on AuthException catch (e) {
      log('❌ خطأ في إرسال OTP: ${e.message}');
      emit(ForgotPasswordFailure(error: _parseAuthError(e)));
    } catch (e) {
      log('❌ خطأ غير متوقع في إرسال OTP: $e');
      emit(
        const ForgotPasswordFailure(
          error: 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        ),
      );
    }
  }

  /// Verify OTP token
  Future<void> verifyOtp({required String email, required String token}) async {
    try {
      // Validate inputs
      final emailError = _validateEmail(email);
      if (emailError != null) {
        emit(
          ForgotPasswordValidationError(fieldName: 'email', error: emailError),
        );
        return;
      }

      final otpError = _validateOtp(token);
      if (otpError != null) {
        emit(ForgotPasswordValidationError(fieldName: 'otp', error: otpError));
        return;
      }

      emit(ForgotPasswordLoading());

      log('🔄 التحقق من OTP للإيميل: $email');

      // Verify OTP with Supabase Auth
      final response = await _supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.session == null || response.user == null) {
        emit(
          const ForgotPasswordFailure(
            error: 'رمز التحقق غير صحيح أو منتهي الصلاحية',
          ),
        );
        return;
      }

      log('✅ تم التحقق من OTP بنجاح');

      emit(
        ForgotPasswordOtpVerified(
          email: email,
          message: 'تم التحقق من رمز الأمان بنجاح',
        ),
      );
    } on AuthException catch (e) {
      log('❌ خطأ في التحقق من OTP: ${e.message}');
      emit(ForgotPasswordFailure(error: _parseAuthError(e)));
    } catch (e) {
      log('❌ خطأ غير متوقع في التحقق من OTP: $e');
      emit(
        const ForgotPasswordFailure(
          error: 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        ),
      );
    }
  }

  /// Update password after OTP verification
  Future<void> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Validate inputs
      final emailError = _validateEmail(email);
      if (emailError != null) {
        emit(
          ForgotPasswordValidationError(fieldName: 'email', error: emailError),
        );
        return;
      }

      final passwordError = _validatePassword(newPassword);
      if (passwordError != null) {
        emit(
          ForgotPasswordValidationError(
            fieldName: 'password',
            error: passwordError,
          ),
        );
        return;
      }

      emit(ForgotPasswordLoading());

      log('🔄 تحديث كلمة المرور للإيميل: $email');

      // Update password in Supabase Auth
      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        emit(const ForgotPasswordFailure(error: 'فشل في تحديث كلمة المرور'));
        return;
      }

      // Also update the password in users table for consistency
      await _updatePasswordInUsersTable(email, newPassword);

      log('✅ تم تحديث كلمة المرور بنجاح');

      emit(
        const ForgotPasswordSuccess(
          message: 'تم تحديث كلمة المرور بنجاح، يمكنك الآن تسجيل الدخول',
        ),
      );
    } on AuthException catch (e) {
      log('❌ خطأ في تحديث كلمة المرور: ${e.message}');
      emit(ForgotPasswordFailure(error: _parseAuthError(e)));
    } catch (e) {
      log('❌ خطأ غير متوقع في تحديث كلمة المرور: $e');
      emit(
        const ForgotPasswordFailure(
          error: 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        ),
      );
    }
  }

  /// Check if email exists in users table
  Future<bool> _checkEmailExistsInUsersTable(String email) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('email')
              .eq('email', email.trim().toLowerCase())
              .maybeSingle();

      return response != null;
    } catch (e) {
      log('❌ خطأ في التحقق من وجود الإيميل: $e');
      return false;
    }
  }

  /// Update password in users table for consistency
  Future<void> _updatePasswordInUsersTable(
    String email,
    String password,
  ) async {
    try {
      await _supabaseClient
          .from('users')
          .update({'password': password})
          .eq('email', email.trim().toLowerCase());

      log('✅ تم تحديث كلمة المرور في جدول المستخدمين');
    } catch (e) {
      log('⚠️ تحذير: فشل في تحديث كلمة المرور في جدول المستخدمين: $e');
      // Don't throw error as the main Auth update succeeded
    }
  }

  /// Validate email format
  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// Validate OTP format
  String? _validateOtp(String? otp) {
    if (otp == null || otp.trim().isEmpty) {
      return 'يرجى إدخال رمز التحقق';
    }

    if (otp.trim().length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otp.trim())) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// Validate password format
  String? _validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'يرجى إدخال كلمة المرور الجديدة';
    }

    if (password.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    if (password.length > 50) {
      return 'كلمة المرور يجب أن تكون أقل من 50 حرف';
    }

    return null;
  }

  /// Parse Supabase Auth errors to user-friendly messages
  String _parseAuthError(AuthException error) {
    switch (error.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'بيانات تسجيل الدخول غير صحيحة';
      case 'email not confirmed':
        return 'يرجى تأكيد البريد الإلكتروني أولاً';
      case 'user not found':
        return 'المستخدم غير موجود';
      case 'otp expired':
        return 'رمز التحقق منتهي الصلاحية';
      case 'invalid otp':
        return 'رمز التحقق غير صحيح';
      case 'too many requests':
        return 'طلبات كثيرة، يرجى المحاولة بعد قليل';
      case 'weak password':
        return 'كلمة المرور ضعيفة، يرجى اختيار كلمة مرور أقوى';
      default:
        return error.message.isNotEmpty
            ? error.message
            : 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    }
  }

  /// Reset cubit to initial state
  void reset() {
    emit(ForgotPasswordInitial());
  }

  /// Clear validation errors
  void clearErrors() {
    if (state is ForgotPasswordFailure ||
        state is ForgotPasswordValidationError) {
      emit(ForgotPasswordInitial());
    }
  }
}
