import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

  // OCR: using Tesseract via ocr_service/ocr_utils. No ML Kit TextRecognizer
  // registration here because the project now uses the `tesseract_ocr` plugin.

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
