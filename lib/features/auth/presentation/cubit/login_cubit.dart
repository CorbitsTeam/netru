import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/login_user_entity.dart';
import '../../domain/usecases/check_user_exists.dart';
import '../../domain/usecases/login_user.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final CheckUserExistsUseCase _checkUserExistsUseCase;
  final LoginUserUseCase _loginUserUseCase;

  LoginCubit({
    required CheckUserExistsUseCase checkUserExistsUseCase,
    required LoginUserUseCase loginUserUseCase,
  }) : _checkUserExistsUseCase = checkUserExistsUseCase,
       _loginUserUseCase = loginUserUseCase,
       super(LoginInitial());

  /// Check if user exists by identifier
  Future<void> checkUserExists(String identifier) async {
    if (identifier.trim().isEmpty) {
      emit(const UserExistsCheckFailure(error: 'Identifier cannot be empty'));
      return;
    }

    emit(UserExistsCheckLoading());

    final result = await _checkUserExistsUseCase(
      CheckUserExistsParams(identifier: identifier.trim()),
    );

    result.fold(
      (failure) => emit(UserExistsCheckFailure(error: failure.message)),
      (exists) => emit(UserExistsCheckSuccess(exists: exists)),
    );
  }

  /// Login user with identifier and password
  Future<void> loginUser({
    required String identifier,
    required String password,
    required UserType userType,
  }) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      emit(const LoginFailure(error: 'Please fill in all required fields'));
      return;
    }

    // Validate identifier based on user type
    final validationError = validateIdentifier(identifier.trim(), userType);
    if (validationError != null) {
      emit(LoginFailure(error: validationError));
      return;
    }

    // Validate password
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      emit(LoginFailure(error: passwordError));
      return;
    }

    emit(LoginLoading());

    final result = await _loginUserUseCase(
      LoginUserParams(
        identifier: identifier.trim(),
        password: password,
        userType: userType,
      ),
    );

    result.fold(
      (failure) => emit(LoginFailure(error: failure.message)),
      (user) => emit(LoginSuccess(user: user)),
    );
  }

  /// Get navigation route based on user type
  String getNavigationRoute(LoginUserEntity user) {
    switch (user.userType) {
      case UserType.citizen:
      case UserType.foreigner:
        return '/home';
      case UserType.admin:
        return '/admin-dashboard';
    }
  }

  /// Validate identifier based on user type
  String? validateIdentifier(String? value, UserType userType) {
    if (value == null || value.trim().isEmpty) {
      switch (userType) {
        case UserType.citizen:
          return 'National ID is required';
        case UserType.foreigner:
          return 'Passport number is required';
        case UserType.admin:
          return 'Email is required';
      }
    }

    switch (userType) {
      case UserType.citizen:
        return _validateNationalId(value.trim());
      case UserType.foreigner:
        return _validatePassportNumber(value.trim());
      case UserType.admin:
        return _validateEmail(value.trim());
    }
  }

  /// Validate Egyptian National ID (14 digits)
  String? _validateNationalId(String nationalId) {
    if (nationalId.length != 14) {
      return 'National ID must be 14 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(nationalId)) {
      return 'National ID must contain only numbers';
    }
    return null;
  }

  /// Validate passport number (basic format check)
  String? _validatePassportNumber(String passportNumber) {
    if (passportNumber.length < 6 || passportNumber.length > 15) {
      return 'Invalid passport number format';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(passportNumber.toUpperCase())) {
      return 'Passport number must contain only letters and numbers';
    }
    return null;
  }

  /// Validate email format
  String? _validateEmail(String email) {
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Reset cubit to initial state
  void resetToInitial() {
    emit(LoginInitial());
  }

  /// Clear any error states
  void clearErrors() {
    if (state is LoginFailure || state is UserExistsCheckFailure) {
      emit(LoginInitial());
    }
  }
}
