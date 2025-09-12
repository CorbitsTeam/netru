import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/location_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_with_email.dart';
import '../domain/usecases/register_user.dart';
import '../presentation/cubit/auth_cubit.dart';
import '../presentation/cubit/signup_cubit.dart';

final sl = GetIt.instance;

Future<void> initAuthDependencies() async {
  // External
  final supabaseClient = Supabase.instance.client;

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: supabaseClient),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));

  // Services
  sl.registerLazySingleton(() => LocationService());

  // Cubits
  sl.registerFactory(
    () => AuthCubit(loginWithEmailUseCase: sl(), authRepository: sl()),
  );

  sl.registerFactory(
    () => SignupCubit(registerUserUseCase: sl(), locationService: sl()),
  );
}
