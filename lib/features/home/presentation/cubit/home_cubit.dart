import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/logger_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final NotificationService _notificationService;
  final LoggerService _logger;

  HomeCubit({NotificationService? notificationService, LoggerService? logger})
    : _notificationService = notificationService ?? NotificationService(),
      _logger = logger ?? LoggerService(),
      super(HomeInitial());

  String? _fcmToken;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize and get FCM token
  Future<void> initializeFcmToken() async {
    emit(HomeLoading());
    try {
      _logger.logInfo('🔄 Initializing FCM token...');

      // Ensure notification service is initialized
      if (!_notificationService.isInitialized) {
        await _notificationService.init();
      }

      // Get FCM token
      final token = await _notificationService.getFcmToken();

      if (token != null) {
        _fcmToken = token;
        _logger.logInfo('✅ FCM token initialized successfully');
        emit(HomeFcmTokenSuccess(token));
      } else {
        _logger.logWarning('⚠️ FCM token is null');
        emit(HomeFailure('Failed to get FCM token'));
      }
    } catch (e) {
      _logger.logError('❌ Error initializing FCM token: $e');
      emit(HomeFailure('Error getting FCM token: $e'));
    }
  }

  /// Get cached FCM token (without API call)
  String? getCachedFcmToken() {
    return _notificationService.cachedFcmToken;
  }

  /// Setup token refresh listener (automatically handled by NotificationService)
  void setupTokenRefreshListener() {
    // Token refresh is now handled automatically by NotificationService
    _logger.logInfo(
      '🔄 Token refresh listener is managed by NotificationService',
    );
  }

  Future<void> doSomething() async {
    emit(HomeLoading());
    try {
      // Call usecase
      // emit(HomeSuccess(result));
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }
}
