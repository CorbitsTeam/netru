import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Specific states for registration
class CitizenRegistrationSuccess extends AuthState {
  final CitizenEntity citizen;

  const CitizenRegistrationSuccess({required this.citizen});

  @override
  List<Object> get props => [citizen];
}

class ForeignerRegistrationSuccess extends AuthState {
  final ForeignerEntity foreigner;

  const ForeignerRegistrationSuccess({required this.foreigner});

  @override
  List<Object> get props => [foreigner];
}
