import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ===========================
// Submission of Report Feature
// ===========================
import '../../features/SubmissionOfaReport/presentation/cubit/submission_report_cubit.dart';
// ===========================
// Auth Feature
// ===========================
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/user_repository.dart';
import '../../features/auth/domain/usecases/check_user_exists.dart';
import '../../features/auth/domain/usecases/get_user_by_id.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/signup_user.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/signup_cubit.dart';
import '../../features/chatbot/data/datasources/chatbot_local_data_source.dart';
// ===========================
// Chatbot Feature
// ===========================
import '../../features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import '../../features/chatbot/data/repositories/chat_repository_impl.dart';
import '../../features/chatbot/domain/repositories/chat_repository.dart';
import '../../features/chatbot/domain/usecases/create_session.dart';
import '../../features/chatbot/domain/usecases/get_help_menu.dart';
import '../../features/chatbot/domain/usecases/get_law_info.dart';
import '../../features/chatbot/domain/usecases/get_session.dart';
import '../../features/chatbot/domain/usecases/get_user_sessions.dart';
import '../../features/chatbot/domain/usecases/send_message.dart';
import '../../features/chatbot/presentation/cubit/chat_cubit.dart';
// ===========================
// News Feature
// ===========================
import '../../features/newsdetails/data/datasources/news_local_datasource.dart';
import '../../features/newsdetails/data/repositories/newsdetails_repository_impl.dart';
import '../../features/newsdetails/domain/repositories/newsdetails_repository.dart';
import '../../features/newsdetails/domain/usecases/newsdetails_usecase.dart';
import '../../features/newsdetails/presentation/cubit/news_cubit.dart';
// ===========================
// Reports Feature
// ===========================
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/reports_usecase.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';
// Core Services
import '../services/location_service.dart';
import '../services/logger_service.dart';

final sl = GetIt.instance;

/// Main dependency injection setup function
Future<void> initializeDependencies() async {
  // ===========================
  // External Dependencies
  // ===========================
  final supabaseClient = Supabase.instance.client;
  sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  sl.registerLazySingleton<LoggerService>(() {
    final logger = LoggerService();
    logger.init();
    return logger;
  });

  sl.registerLazySingleton<Dio>(() => Dio());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton(() => LocationService());

  // ===========================
  // Feature Dependencies
  // ===========================
  await _initAuthDependencies();
  await _initChatbotDependencies();
  await _initNewsDependencies();
  await _initReportsDependencies();

  sl.get<LoggerService>().logInfo(
    '✅ All dependencies have been initialized successfully',
  );
}

/// ===========================
/// Auth
/// ===========================
Future<void> _initAuthDependencies() async {
  final supabaseClient = sl<SupabaseClient>();

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: supabaseClient),
  );

  sl.registerLazySingleton<UserDataSource>(
    () => SupabaseUserDataSource(supabaseClient: supabaseClient),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserExistsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUserUseCase(userRepository: sl()));

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

/// ===========================
/// Chatbot
/// ===========================
Future<void> _initChatbotDependencies() async {
  sl.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotRemoteDataSourceImpl(
      dio: sl(),
      groqApiKey:
          'gsk_replace_with_actual_key', // ⚠️ Replace with your actual key
    ),
  );

  sl.registerLazySingleton<ChatbotLocalDataSource>(
    () => ChatbotLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      uuid: sl(),
    ),
  );

  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => CreateSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetHelpMenuUseCase(sl()));
  sl.registerLazySingleton(() => GetLawInfoUseCase(sl()));

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

/// ===========================
/// News
/// ===========================
Future<void> _initNewsDependencies() async {
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NewsdetailsRepository>(
    () => NewsdetailsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => NewsdetailsUseCase(sl()));
  sl.registerFactory(() => NewsCubit(sl()));

  sl.get<LoggerService>().logInfo('✅ News dependencies initialized');
}

/// ===========================
/// Reports
/// ===========================
Future<void> _initReportsDependencies() async {
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetAllReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetReportByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReportStatusUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReportUseCase(sl()));

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

/// ===========================
/// Helpers
/// ===========================
Future<void> resetDependencies() async {
  await sl.reset();
  await initializeDependencies();
}

T getDependency<T extends Object>() => sl.get<T>();

bool isDependencyRegistered<T extends Object>() => sl.isRegistered<T>();
