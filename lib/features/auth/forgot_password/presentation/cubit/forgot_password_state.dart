import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email;
  final String message;

  const ForgotPasswordOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String message;

  const ForgotPasswordOtpVerified({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  const ForgotPasswordFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ForgotPasswordValidationError extends ForgotPasswordState {
  final String fieldName;
  final String error;

  const ForgotPasswordValidationError({
    required this.fieldName,
    required this.error,
  });

  @override
  List<Object?> get props => [fieldName, error];
}
