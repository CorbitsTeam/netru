import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Verification feature imports
import '../../features/verification/data/datasources/verification_remote_data_source.dart';
import '../../features/verification/data/datasources/document_scanner_service.dart';
import '../../features/verification/data/repositories/verification_repository_impl.dart';
import '../../features/verification/domain/repositories/verification_repository.dart';
import '../../features/verification/domain/usecases/scan_document.dart';
import '../../features/verification/domain/usecases/save_identity_document.dart';
import '../../features/verification/domain/usecases/get_user_documents.dart';
import '../../features/verification/domain/usecases/check_verification_status.dart';
import '../../features/verification/presentation/cubit/verification_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ===========================
  // External Dependencies
  // ===========================

  // Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Logger
  sl.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    ),
  );

  // UUID generator
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Google ML Kit Text Recognizer
  sl.registerLazySingleton<TextRecognizer>(() => TextRecognizer());

  // ===========================
  // Verification Feature
  // ===========================

  // Data sources
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(supabaseClient: sl(), uuid: sl()),
  );

  sl.registerLazySingleton<DocumentScannerService>(
    () => DocumentScannerServiceImpl(textRecognizer: sl(), logger: sl()),
  );

  // Repository
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(
      remoteDataSource: sl(),
      documentScannerService: sl(),
      logger: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScanDocumentUseCase(sl()));
  sl.registerLazySingleton(() => SaveIdentityDocumentUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => CheckVerificationStatusUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => VerificationCubit(
      scanDocumentUseCase: sl(),
      saveIdentityDocumentUseCase: sl(),
      getUserDocumentsUseCase: sl(),
      checkVerificationStatusUseCase: sl(),
      logger: sl(),
    ),
  );

  // ===========================
  // Auth Feature
  // ===========================

  // Add your existing auth dependencies here
  // For example:
  // sl.registerFactory(() => AuthCubit(...));

  sl.get<Logger>().i('All dependencies have been initialized successfully');
}

/// Helper method to reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await initializeDependencies();
}
