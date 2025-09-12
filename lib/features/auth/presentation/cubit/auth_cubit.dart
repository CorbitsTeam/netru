import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/register_citizen.dart';
import '../../domain/usecases/register_foreigner.dart';
import '../../domain/usecases/signin_with_google.dart';
import '../../domain/usecases/signup_with_email.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final RegisterCitizenUseCase registerCitizenUseCase;
  final RegisterForeignerUseCase registerForeignerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final IsUserLoggedInUseCase isUserLoggedInUseCase;

  AuthCubit({
    required this.loginWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signInWithGoogleUseCase,
    required this.registerCitizenUseCase,
    required this.registerForeignerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.isUserLoggedInUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await isUserLoggedInUseCase(const NoParams());

    result.fold((failure) => emit(AuthUnauthenticated()), (isLoggedIn) async {
      if (isLoggedIn) {
        await getCurrentUser();
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginWithEmailUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(AuthLoading());

    final result = await signUpWithEmailUseCase(
      SignUpParams(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    final result = await signInWithGoogleUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
    String? address,
  }) async {
    emit(AuthLoading());

    final result = await registerCitizenUseCase(
      RegisterCitizenParams(
        email: email,
        password: password,
        fullName: fullName,
        nationalId: nationalId,
        phone: phone,
        address: address,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (citizen) => emit(CitizenRegistrationSuccess(citizen: citizen)),
    );
  }

  Future<void> registerForeigner({
    required String email,
    required String password,
    required String fullName,
    required String passportNumber,
    required String nationality,
    required String phone,
  }) async {
    emit(AuthLoading());

    final result = await registerForeignerUseCase(
      RegisterForeignerParams(
        email: email,
        password: password,
        fullName: fullName,
        passportNumber: passportNumber,
        nationality: nationality,
        phone: phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (foreigner) => emit(ForeignerRegistrationSuccess(foreigner: foreigner)),
    );
  }

  Future<void> getCurrentUser() async {
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // Validation helper methods
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حروف كبيرة وصغيرة وأرقام';
    }
    return null;
  }

  String? validateNationalId(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) {
      return 'الرقم القومي مطلوب';
    }
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }
    return null;
  }

  String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(phone)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  String? validateFullName(String? name) {
    if (name == null || name.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }
    if (name.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }
}
