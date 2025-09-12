import 'package:get_it/get_it.dart';

// Services
import '../services/logger_service.dart';

// Data Sources
// import '../data/datasources/permission_datasource.dart';

// Repositories
// import '../domain/repositories/permission_repository.dart';
// import '../data/repositories/permission_repository_impl.dart';

// Use Cases
// import '../domain/usecases/permission_usecases.dart';

// Cubits
// import '../cubit/permission/permission_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ===========================================
  // 🛠️ Core Services
  // ===========================================

  sl.registerLazySingleton<LoggerService>(() {
    final logger = LoggerService();
    logger.init();
    return logger;
  });

  // ===========================================
  // 📊 Data Sources
  // ===========================================

  // Permission Data Source
  // sl.registerLazySingleton<PermissionDataSource>(
  //   () => PermissionDataSourceImpl(),
  // );

  // ===========================================
  // 📁 Repositories
  // ===========================================

  // Permission Repository
  // sl.registerLazySingleton<PermissionRepository>(
  //   () => PermissionRepositoryImpl(dataSource: sl()),
  // );

  // ===========================================
  // ⚡ Use Cases
  // ===========================================

  // Permission Use Cases
  // sl.registerLazySingleton(() => CheckPermissionUseCase(sl()));
  // sl.registerLazySingleton(() => RequestPermissionUseCase(sl()));
  // sl.registerLazySingleton(() => RequestMultiplePermissionsUseCase(sl()));
  // sl.registerLazySingleton(() => OpenAppSettingsUseCase(sl()));
  // sl.registerLazySingleton(() => GetAllPermissionsStatusUseCase(sl()));

  // ===========================================
  // 🎯 Cubits/Blocs
  // ===========================================

  // Permission Cubit
  // sl.registerFactory(
  //   () => PermissionCubit(
  //     checkPermissionUseCase: sl(),
  //     requestPermissionUseCase: sl(),
  //     requestMultiplePermissionsUseCase: sl(),
  //     openAppSettingsUseCase: sl(),
  //     getAllPermissionsStatusUseCase: sl(),
  //   ),
  // );
}
