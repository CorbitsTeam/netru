/// Forgot Password Entry Point
///
/// This file provides an easy way to test the forgot password functionality.
///
/// Usage:
/// 1. Navigate to forgot password from login screen
/// 2. Enter email and receive OTP
/// 3. Verify OTP and set new password
///
/// Features:
/// - Email validation with user existence check
/// - OTP verification using Supabase Auth
/// - Password update in both Supabase Auth and users table
/// - Consistent UI design with app theme
/// - Comprehensive error handling
/// - Arabic localization
///
/// Pages included:
/// - ForgotPasswordEmailPage: Email input and OTP sending
/// - OtpVerificationPage: OTP verification and password reset
///
/// Navigation routes:
/// - /forgotPasswordEmail: Email input page
/// - /forgotPasswordOtp: OTP verification page (with email argument)
///
/// BLoC State Management:
/// - ForgotPasswordCubit: Manages forgot password flow
/// - ForgotPasswordState: Various states for UI updates
///
/// How to access:
/// - From login screen: Click "نسيت كلمة المرور؟" link
/// - Or navigate directly using Navigator.pushNamed(context, '/forgotPasswordEmail')

export 'presentation/cubit/forgot_password_cubit.dart';
export 'presentation/cubit/forgot_password_state.dart';
export 'presentation/pages/forgot_password_email_page.dart';
export 'presentation/pages/otp_verification_page.dart';
