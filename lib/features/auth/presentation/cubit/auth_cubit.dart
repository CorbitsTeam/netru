import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_with_national_id.dart';
import '../../domain/usecases/login_with_passport.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithNationalIdUseCase _loginWithNationalIdUseCase;
  final LoginWithPassportUseCase _loginWithPassportUseCase;
  final AuthRepository _authRepository;

  AuthCubit({
    required LoginWithNationalIdUseCase loginWithNationalIdUseCase,
    required LoginWithPassportUseCase loginWithPassportUseCase,
    required AuthRepository authRepository,
  }) : _loginWithNationalIdUseCase = loginWithNationalIdUseCase,
       _loginWithPassportUseCase = loginWithPassportUseCase,
       _authRepository = authRepository,
       super(AuthInitial());

  Future<void> loginWithNationalId({
    required String nationalId,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _loginWithNationalIdUseCase(
      LoginWithNationalIdParams(nationalId: nationalId, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthLoggedIn(user: user)),
    );
  }

  Future<void> loginWithPassport({
    required String passportNumber,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _loginWithPassportUseCase(
      LoginWithPassportParams(
        passportNumber: passportNumber,
        password: password,
      ),
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
