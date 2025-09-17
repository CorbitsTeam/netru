import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import '../services/location_service.dart';
import '../services/logger_service.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/user_repository.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/check_user_exists.dart';
import '../../features/auth/domain/usecases/get_user_by_id.dart';
import '../../features/auth/domain/usecases/signup_user.dart';
import '../../features/auth/presentation/cubit/signup_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';

// Chatbot Feature
import '../../features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import '../../features/chatbot/data/datasources/chatbot_local_data_source.dart';
import '../../features/chatbot/data/repositories/chat_repository_impl.dart';
import '../../features/chatbot/domain/repositories/chat_repository.dart';
import '../../features/chatbot/domain/usecases/send_message.dart';
import '../../features/chatbot/domain/usecases/create_session.dart';
import '../../features/chatbot/domain/usecases/get_session.dart';
import '../../features/chatbot/domain/usecases/get_user_sessions.dart';
import '../../features/chatbot/domain/usecases/get_help_menu.dart';
import '../../features/chatbot/domain/usecases/get_law_info.dart';
import '../../features/chatbot/presentation/cubit/chat_cubit.dart';

// Reports Feature
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/reports_usecase.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';

// Submission of Report Feature
import '../../features/SubmissionOfaReport/presentation/cubit/submission_report_cubit.dart';

final sl = GetIt.instance;

/// Main dependency injection setup function
/// This initializes all dependencies for the entire application
Future<void> initializeDependencies() async {
  // ===========================
  // External Dependencies
  // ===========================

  // Supabase
  final supabaseClient = Supabase.instance.client;
  sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // Logger
  sl.registerLazySingleton<LoggerService>(() {
    final logger = LoggerService();
    logger.init();
    return logger;
  });

  // Dio
  sl.registerLazySingleton<Dio>(() => Dio());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // UUID
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Location Service
  sl.registerLazySingleton(() => LocationService());

  // ===========================
  // Auth Feature Dependencies
  // ===========================

  await _initAuthDependencies();

  // ===========================
  // Chatbot Feature Dependencies
  // ===========================

  await _initChatbotDependencies();

  // ===========================
  // Reports Feature Dependencies
  // ===========================

  await _initReportsDependencies();

  sl.get<LoggerService>().logInfo(
    '✅ All dependencies have been initialized successfully',
  );
}

/// Initialize Auth feature dependencies
Future<void> _initAuthDependencies() async {
  final supabaseClient = sl<SupabaseClient>();

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: supabaseClient),
  );

  sl.registerLazySingleton<UserDataSource>(
    () => SupabaseUserDataSource(supabaseClient: supabaseClient),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserExistsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUserUseCase(userRepository: sl()));

  // Cubits
  sl.registerFactory(
    () => SignupCubit(
      registerUserUseCase: sl(),
      signUpUserUseCase: sl(),
      locationService: sl(),
    ),
  );

  sl.registerFactory(
    () => LoginCubit(checkUserExistsUseCase: sl(), loginUserUseCase: sl()),
  );

  sl.get<LoggerService>().logInfo('✅ Auth dependencies initialized');
}

/// Initialize Chatbot feature dependencies
Future<void> _initChatbotDependencies() async {
  // Data sources
  sl.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotRemoteDataSourceImpl(
      dio: sl(),
      groqApiKey:
          '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', // Replace with actual key
    ),
  );

  sl.registerLazySingleton<ChatbotLocalDataSource>(
    () => ChatbotLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      uuid: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => CreateSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetHelpMenuUseCase(sl()));
  sl.registerLazySingleton(() => GetLawInfoUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => ChatCubit(
      sendMessageUseCase: sl(),
      createSessionUseCase: sl(),
      getSessionUseCase: sl(),
      getUserSessionsUseCase: sl(),
      getHelpMenuUseCase: sl(),
      getLawInfoUseCase: sl(),
      authRepository: sl(),
      uuid: sl(),
    ),
  );

  sl.get<LoggerService>().logInfo('✅ Chatbot dependencies initialized');
}

/// Initialize Reports feature dependencies
Future<void> _initReportsDependencies() async {
  // Data sources
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetReportByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReportStatusUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReportUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => ReportsCubit(
      getAllReportsUseCase: sl(),
      getReportByIdUseCase: sl(),
      updateReportStatusUseCase: sl(),
      deleteReportUseCase: sl(),
    ),
  );

  sl.registerFactory(() => ReportFormCubit(createReportUseCase: sl()));

  sl.get<LoggerService>().logInfo('✅ Reports dependencies initialized');
}

/// Helper method to reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await initializeDependencies();
}

/// Get dependency by type (helper method)
T getDependency<T extends Object>() => sl.get<T>();

/// Check if dependency is registered
bool isDependencyRegistered<T extends Object>() => sl.isRegistered<T>();
