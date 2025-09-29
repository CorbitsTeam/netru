import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:netru_app/core/services/admin_notifications_service.dart';
import 'package:netru_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_cubit.dart';
import 'package:netru_app/features/auth/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:netru_app/core/services/simple_fcm_service.dart';
import 'package:netru_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:netru_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:netru_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:netru_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:netru_app/features/notifications/domain/usecases/get_unread_notifications_count.dart';
import 'package:netru_app/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:netru_app/features/notifications/domain/usecases/register_fcm_token.dart';
import 'package:netru_app/features/notifications/domain/usecases/send_notification.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ===========================
// Auth Feature - Unified & Refactored
// ===========================
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/validate_critical_data.dart';
import '../../features/auth/domain/usecases/check_data_exists.dart';
import '../../features/auth/domain/usecases/profile_completion_usecases.dart';
import '../../features/auth/domain/usecases/get_user_by_id.dart';
import '../../features/auth/domain/usecases/signup_with_data.dart';
import '../../features/auth/domain/usecases/update_user_profile.dart';
import '../../features/auth/domain/usecases/upload_profile_image.dart';
import '../../features/auth/profile_completion/presentation/cubit/profile_completion_cubit.dart';

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
// Home Feature
// ===========================
import '../../features/home/presentation/cubit/home_cubit.dart';
// ===========================
// News Feature
// ===========================
import '../../features/news/data/datasources/newsdetails_remote_datasource.dart';
import '../../features/news/data/repositories/newsdetails_repository_impl.dart';
import '../../features/news/domain/repositories/newsdetails_repository.dart';
import '../../features/news/domain/usecases/newsdetails_usecase.dart';
import '../../features/news/presentation/cubit/news_cubit.dart';
// ===========================
// Reports Feature
// ===========================
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/reports_usecase.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';
import '../../features/reports/presentation/cubit/report_form_cubit.dart';
// ===========================
// Cases Feature
// ===========================
import '../../features/cases/data/datasources/cases_remote_datasource.dart';
import '../../features/cases/data/repositories/cases_repository_impl.dart';
import '../../features/cases/domain/repositories/cases_repository.dart';
import '../../features/cases/domain/usecases/cases_usecase.dart';
import '../../features/cases/presentation/cubit/cases_cubit.dart';
// ===========================
// Heatmap Feature
// ===========================
import '../../features/heatmap/data/datasources/heatmap_remote_datasource.dart';
import '../../features/heatmap/data/repositories/heatmap_repository_impl.dart';
import '../../features/heatmap/domain/repositories/heatmap_repository.dart';
import '../../features/heatmap/domain/usecases/heatmap_usecase.dart';
import '../../features/heatmap/presentation/cubit/heatmap_cubit.dart';
// Core Services
import '../services/location_service.dart';
import '../services/logger_service.dart';
import '../services/report_types_service.dart';
import '../services/supabase_edge_functions_service.dart';
import '../services/simple_notification_service.dart';
import '../services/report_notification_service.dart';
import '../network/api_client.dart';

// Admin Feature
import '../../features/admin/data/datasources/admin_dashboard_remote_data_source.dart';
import '../../features/admin/data/datasources/admin_auth_manager_data_source.dart';
import '../../features/admin/data/datasources/admin_user_remote_data_source.dart';
import '../../features/admin/data/datasources/admin_report_remote_data_source.dart';
import '../../features/admin/data/datasources/admin_notification_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_dashboard_repository_impl.dart';
import '../../features/admin/data/repositories/admin_auth_manager_repository_impl.dart';
import '../../features/admin/data/repositories/admin_user_repository_impl.dart';
import '../../features/admin/data/repositories/admin_report_repository_impl.dart';
import '../../features/admin/data/repositories/admin_notification_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_dashboard_repository.dart';
import '../../features/admin/domain/repositories/admin_user_repository.dart';
import '../../features/admin/domain/repositories/admin_report_repository.dart';
import '../../features/admin/domain/repositories/admin_notification_repository.dart';
import '../../features/admin/domain/usecases/get_dashboard_stats.dart';
import '../../features/admin/domain/usecases/get_recent_activities.dart';
import '../../features/admin/domain/usecases/manage_auth_accounts.dart';
import '../../features/admin/domain/usecases/manage_users.dart';
import '../../features/admin/domain/usecases/manage_reports.dart';
import '../../features/admin/domain/usecases/manage_notifications.dart';
import '../../features/admin/presentation/cubit/admin_reports_cubit.dart';
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import '../../features/admin/presentation/cubit/admin_auth_manager_cubit.dart';
import '../../features/admin/presentation/cubit/admin_users_cubit.dart';
import '../../features/admin/presentation/cubit/admin_notifications_cubit.dart';

// ===========================
// External Dependencies
// ===========================
import 'package:firebase_messaging/firebase_messaging.dart';

// ===========================

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
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

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
  await _initCasesDependencies();
  await initNotificationDependencies();
  await _initHeatmapDependencies();
  await _initAdminDependencies();

  sl.get<LoggerService>().logInfo(
    '✅ All dependencies have been initialized successfully',
  );
}

/// ===========================
/// Heatmap
/// ===========================
Future<void> _initHeatmapDependencies() async {
  sl.registerLazySingleton<HeatmapRemoteDataSource>(
    () => HeatmapRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<HeatmapRepository>(
    () => HeatmapRepositoryImpl(sl<HeatmapRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => HeatmapUseCase(sl<HeatmapRepository>()));

  sl.registerFactory(() => HeatmapCubit(sl<HeatmapUseCase>()));

  sl.get<LoggerService>().logInfo('✅ Heatmap dependencies initialized');
}

/// ===========================
/// Auth - Unified & Refactored
/// ===========================
Future<void> _initAuthDependencies() async {
  final supabaseClient = sl<SupabaseClient>();

  // Unified Auth Data Source
  sl.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSource(supabaseClient: supabaseClient),
  );

  // Unified Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );

  // Validation Use Cases
  sl.registerLazySingleton(() => ValidateCriticalDataUseCase(sl()));
  sl.registerLazySingleton(() => CheckEmailExistsInUsersUseCase(sl()));
  // Register use-case that checks whether an email exists in Supabase Auth
  sl.registerLazySingleton(() => CheckEmailExistsInAuthUseCase(sl()));
  sl.registerLazySingleton(() => CheckPhoneExistsUseCase(sl()));
  sl.registerLazySingleton(() => CheckNationalIdExistsUseCase(sl()));
  sl.registerLazySingleton(() => CheckPassportExistsUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserExistsUseCase(sl()));

  // Auth Use Cases
  sl.registerLazySingleton(() => RegisterUserUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  // Ensure update profile and upload profile image use-cases are registered
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithDataUseCase(sl()));

  // Profile Completion Use Cases
  sl.registerLazySingleton(() => CompleteProfileUseCase(sl(), sl()));
  sl.registerLazySingleton(() => VerifyEmailAndCompleteSignupUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailOnlyUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => SignupCubit(
      registerUserUseCase: sl(),
      signUpWithDataUseCase: sl(),
      locationService: sl(),
      checkEmailExistsInUsersUseCase: sl(),
      checkEmailExistsInAuthUseCase: sl(),
      checkPhoneExistsUseCase: sl(),
      checkNationalIdExistsUseCase: sl(),
      checkPassportExistsUseCase: sl(),
    ),
  );

  sl.registerFactory(() => LoginCubit(loginUserUseCase: sl()));

  // Forgot Password Cubit
  sl.registerFactory(() => ForgotPasswordCubit(supabaseClient: sl()));

  // Profile Completion Cubit
  sl.registerFactory(
    () => ProfileCompletionCubit(
      completeProfileUseCase: sl(),
      verifyEmailAndCompleteSignupUseCase: sl(),
      resendVerificationEmailUseCase: sl(),
      validateCriticalDataUseCase: sl(),
      checkPhoneExistsUseCase: sl(),
      checkNationalIdExistsUseCase: sl(),
      checkPassportExistsUseCase: sl(),
      checkEmailExistsInUsersUseCase: sl(),
    ),
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
      groqApiKey: '', // ⚠️ Replace with your actual key
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

      uuid: sl(),
    ),
  );

  sl.get<LoggerService>().logInfo('✅ Chatbot dependencies initialized');
}

/// ===========================
/// News
/// ===========================
Future<void> _initNewsDependencies() async {
  sl.registerLazySingleton<NewsdetailsRemoteDataSource>(
    () => NewsdetailsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<NewsdetailsRepository>(
    () => NewsdetailsRepositoryImpl(sl<NewsdetailsRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => NewsdetailsUseCase(sl()));
  // Register NewsCubit as a lazy singleton so it remains available app-wide
  sl.registerLazySingleton<NewsCubit>(() => NewsCubit(sl()));

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

  sl.registerLazySingleton<ReportTypesService>(() {
    final service = ReportTypesService();
    service.initialize();
    return service;
  });

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

  sl.registerFactory(
    () => ReportFormCubit(createReportUseCase: sl(), reportTypesService: sl()),
  );

  sl.get<LoggerService>().logInfo('✅ Reports dependencies initialized');
}

/// ===========================
/// Cases
/// ===========================
Future<void> _initCasesDependencies() async {
  sl.registerLazySingleton<CasesRemoteDataSource>(
    () => CasesRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CasesRepository>(() => CasesRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CasesUseCase(sl()));

  sl.registerFactory(() => CasesCubit(sl()));

  sl.get<LoggerService>().logInfo('✅ Cases dependencies initialized');
}

Future<void> initNotificationDependencies() async {
  // External dependencies (should be registered in main DI)
  if (!sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio());
  }

  if (!sl.isRegistered<FirebaseMessaging>()) {
    sl.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );
  }

  // Data Sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () =>
        NotificationRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );

  // Note: SimpleFcmService is a singleton, no need to register

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl<NotificationRemoteDataSource>(),
      fcmService: SimpleFcmService(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => GetUnreadNotificationsCountUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkNotificationAsReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => SendNotificationUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterFcmTokenUseCase(sl<NotificationRepository>()),
  );

  // Presentation (Cubit)
  sl.registerFactory(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      getUnreadCountUseCase: sl<GetUnreadNotificationsCountUseCase>(),
      markAsReadUseCase: sl<MarkNotificationAsReadUseCase>(),
      sendNotificationUseCase: sl<SendNotificationUseCase>(),
      notificationRepository: sl<NotificationRepository>(),
    ),
  );

  // ===========================
  // Home Feature
  // ===========================
  sl.registerFactory(() => HomeCubit());
}

/// ===========================
/// Admin
/// ===========================
Future<void> _initAdminDependencies() async {
  // Register Supabase Edge Functions Service
  sl.registerLazySingleton<SupabaseEdgeFunctionsService>(
    () => SupabaseEdgeFunctionsService(),
  );

  // Admin Dashboard data source
  sl.registerLazySingleton<AdminDashboardRemoteDataSource>(
    () => AdminDashboardRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      edgeFunctionsService: sl<SupabaseEdgeFunctionsService>(),
    ),
  );

  // Admin Auth Manager data source
  sl.registerLazySingleton<AdminAuthManagerRemoteDataSource>(
    () => AdminAuthManagerRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
      apiClient: sl<ApiClient>(),
    ),
  );

  // Admin User data source
  sl.registerLazySingleton<AdminUserRemoteDataSource>(
    () => AdminUserRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
      edgeFunctionsService: sl<SupabaseEdgeFunctionsService>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AdminDashboardRepository>(
    () => AdminDashboardRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdminUserRepository>(
    () => AdminUserRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdminAuthManagerRepository>(
    () => AdminAuthManagerRepositoryImpl(
      remoteDataSource: sl<AdminAuthManagerRemoteDataSource>(),
    ),
  );

  // Use cases - Dashboard
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton(() => GetRecentActivities(sl()));
  sl.registerLazySingleton(() => GetReportTrends(sl()));
  sl.registerLazySingleton(() => GetReportsByGovernorate(sl()));
  sl.registerLazySingleton(() => GetReportsByType(sl()));
  sl.registerLazySingleton(() => GetReportsByStatus(sl()));

  // Simple Notification Service
  sl.registerLazySingleton<SimpleNotificationService>(
    () => SimpleNotificationService(),
  );

  // Report Notification Service
  sl.registerLazySingleton<ReportNotificationService>(
    () => ReportNotificationService(),
  );

  // Admin Reports - data source & repository
  sl.registerLazySingleton<AdminReportRemoteDataSource>(
    () => AdminReportRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
      notificationService: sl<SimpleNotificationService>(),
      reportNotificationService: sl<ReportNotificationService>(),
    ),
  );

  sl.registerLazySingleton<AdminReportRepository>(
    () => AdminReportRepositoryImpl(remoteDataSource: sl()),
  );

  // Admin Reports - Use cases
  sl.registerLazySingleton(() => GetAllReports(sl()));
  sl.registerLazySingleton(() => GetReportById(sl()));
  sl.registerLazySingleton(() => UpdateReportStatus(sl()));
  sl.registerLazySingleton(() => AssignReport(sl()));
  sl.registerLazySingleton(() => VerifyReport(sl()));
  sl.registerLazySingleton(() => AddReportComment(sl()));
  sl.registerLazySingleton(() => AdminNotificationsService());

  // Admin Notifications - data source & repository
  sl.registerLazySingleton<AdminNotificationRemoteDataSource>(
    () => AdminNotificationRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      edgeFunctionsService: sl<SupabaseEdgeFunctionsService>(),
      adminNotificationsService: sl<AdminNotificationsService>(),
    ),
  );

  sl.registerLazySingleton<AdminNotificationRepository>(
    () => AdminNotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Admin Notifications - Use cases
  sl.registerLazySingleton(() => SendBulkNotification(sl()));
  sl.registerLazySingleton(() => GetAllNotifications(sl()));
  sl.registerLazySingleton(() => CreateNotification(sl()));
  sl.registerLazySingleton(() => GetNotificationStats(sl()));
  sl.registerLazySingleton(() => GetGovernoratesList(sl()));
  sl.registerLazySingleton(() => GetUserNotifications(sl()));

  // Use cases - Auth Manager
  sl.registerLazySingleton(() => GetUsersWithoutAuthAccount(sl()));
  sl.registerLazySingleton(() => CreateAuthAccountForUser(sl()));
  sl.registerLazySingleton(() => CreateAuthAccountsForAllUsers(sl()));
  sl.registerLazySingleton(() => CheckUserHasAuthAccount(sl()));

  // Use cases - User Management
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => GetUserById(sl()));
  sl.registerLazySingleton(() => GetUserDetailedProfile(sl()));
  sl.registerLazySingleton(() => VerifyUser(sl()));
  sl.registerLazySingleton(() => SuspendUser(sl()));

  // Cubits
  sl.registerFactory(
    () =>
        AdminDashboardCubit(getDashboardStats: sl(), getRecentActivities: sl()),
  );

  sl.registerFactory(
    () => AdminReportsCubit(
      getAllReports: sl(),
      getReportById: sl(),
      updateReportStatus: sl(),
      assignReport: sl(),
      verifyReport: sl(),
      addReportComment: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminAuthManagerCubit(
      getUsersWithoutAuthAccount: sl(),
      createAuthAccountForUser: sl(),
      createAuthAccountsForAllUsers: sl(),
      checkUserHasAuthAccount: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminUsersCubit(
      getAllUsers: sl(),
      verifyUser: sl(),
      suspendUser: sl(),
      getUserDetailedProfile: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminNotificationsCubit(
      sl<SendBulkNotification>(),
      sl<GetAllNotifications>(),
      sl<CreateNotification>(),
      sl<GetNotificationStats>(),
      sl<GetGovernoratesList>(),
      sl<GetUserNotifications>(),
    ),
  );

  sl.get<LoggerService>().logInfo('✅ Admin dependencies initialized');
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
