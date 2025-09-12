import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final AuthRepository _authRepository;

  AuthCubit({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required AuthRepository authRepository,
  }) : _loginWithEmailUseCase = loginWithEmailUseCase,
       _authRepository = authRepository,
       super(AuthInitial());

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _loginWithEmailUseCase(
      LoginWithEmailParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthLoggedIn(user: user)),
    );
  }

  Future<void> checkCurrentUser() async {
    emit(AuthLoading());

    final result = await _authRepository.getCurrentUser();

    result.fold((failure) => emit(AuthLoggedOut()), (user) {
      if (user != null) {
        emit(AuthLoggedIn(user: user));
      } else {
        emit(AuthLoggedOut());
      }
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthLoggedOut()),
    );
  }

  void resetToInitial() {
    emit(AuthInitial());
  }
}
