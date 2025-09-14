import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Data Sources
import '../data/datasources/chatbot_remote_data_source.dart';
import '../data/datasources/chatbot_local_data_source.dart';

// Repositories
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';

// Use Cases
import '../domain/usecases/send_message.dart';
import '../domain/usecases/create_session.dart';
import '../domain/usecases/get_session.dart';
import '../domain/usecases/get_user_sessions.dart';
import '../domain/usecases/get_help_menu.dart';
import '../domain/usecases/get_law_info.dart';

// Cubit
import '../presentation/cubit/chat_cubit.dart';

// Import auth repository from auth module
import '../../auth/domain/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> initChatbotDependencies() async {
  // External dependencies (register if not already registered)
  if (!getIt.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  if (!getIt.isRegistered<Dio>()) {
    final dio = Dio();
    getIt.registerLazySingleton<Dio>(() => dio);
  }

  if (!getIt.isRegistered<Uuid>()) {
    const uuid = Uuid();
    getIt.registerLazySingleton<Uuid>(() => uuid);
  }

  // Data Sources
  getIt.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      groqApiKey:
          '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', // Should be from env
    ),
  );

  getIt.registerLazySingleton<ChatbotLocalDataSource>(
    () => ChatbotLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatbotRemoteDataSource>(),
      localDataSource: getIt<ChatbotLocalDataSource>(),
      uuid: getIt<Uuid>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => SendMessageUseCase(getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateSessionUseCase(getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(() => GetSessionUseCase(getIt<ChatRepository>()));
  getIt.registerLazySingleton(
    () => GetUserSessionsUseCase(getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetHelpMenuUseCase(getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(() => GetLawInfoUseCase(getIt<ChatRepository>()));

  // Cubit
  getIt.registerFactory(
    () => ChatCubit(
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      createSessionUseCase: getIt<CreateSessionUseCase>(),
      getSessionUseCase: getIt<GetSessionUseCase>(),
      getUserSessionsUseCase: getIt<GetUserSessionsUseCase>(),
      getHelpMenuUseCase: getIt<GetHelpMenuUseCase>(),
      getLawInfoUseCase: getIt<GetLawInfoUseCase>(),
      authRepository:
          getIt<AuthRepository>(), // This should be injected from auth module
      uuid: getIt<Uuid>(),
    ),
  );
}
