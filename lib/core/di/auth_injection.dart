import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/register_citizen.dart';
import '../../features/auth/domain/usecases/register_foreigner.dart';
import '../../features/auth/domain/usecases/signin_with_google.dart';
import '../../features/auth/domain/usecases/signup_with_email.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initAuthDependencies() async {
  // External dependencies
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl(), googleSignIn: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => RegisterCitizenUseCase(sl()));
  sl.registerLazySingleton(() => RegisterForeignerUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => IsUserLoggedInUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginWithEmailUseCase: sl(),
      signUpWithEmailUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      registerCitizenUseCase: sl(),
      registerForeignerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
      isUserLoggedInUseCase: sl(),
    ),
  );
}
