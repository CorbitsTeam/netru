import 'package:equatable/equatable.dart';
import '../../domain/entities/login_user_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginUserEntity user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class UserExistsCheckLoading extends LoginState {}

class UserExistsCheckSuccess extends LoginState {
  final bool exists;

  const UserExistsCheckSuccess({required this.exists});

  @override
  List<Object?> get props => [exists];
}

class UserExistsCheckFailure extends LoginState {
  final String error;

  const UserExistsCheckFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
