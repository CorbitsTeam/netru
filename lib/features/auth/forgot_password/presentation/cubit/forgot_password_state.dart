import 'package:equatable/equatable.dart';

enum PasswordResetStep { emailInput, emailSent, newPasswordInput, completed }

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

// Step 1: Password reset token sent successfully
class TokenSent extends ForgotPasswordState {
  final String email;
  final String message;

  const TokenSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// Step 2: Token verified successfully
class TokenVerified extends ForgotPasswordState {
  final String email;
  final String token;
  final String message;

  const TokenVerified({
    required this.email,
    required this.token,
    required this.message,
  });

  @override
  List<Object?> get props => [email, token, message];
}

// Legacy state for backward compatibility
@deprecated
class PasswordResetEmailSent extends ForgotPasswordState {
  final String email;
  final String message;

  const PasswordResetEmailSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// Step 3: Password reset completed
class PasswordResetSuccess extends ForgotPasswordState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;
  final PasswordResetStep currentStep;

  const ForgotPasswordFailure({required this.error, required this.currentStep});

  @override
  List<Object?> get props => [error, currentStep];
}
