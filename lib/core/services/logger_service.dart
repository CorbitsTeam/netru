import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  late final Logger _logger;

  void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  void logInfo(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void logDebug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void logWarning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void logFatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Specific logging methods for different app events
  void logApiRequest(String method, String url, Map<String, dynamic>? data) {
    logInfo('🌐 API Request: $method $url', data);
  }

  void logApiResponse(
    String method,
    String url,
    int statusCode,
    dynamic response,
  ) {
    logInfo('✅ API Response: $method $url - Status: $statusCode', response);
  }

  void logApiError(String method, String url, dynamic error) {
    logError('❌ API Error: $method $url', error);
  }

  void logPermissionRequest(String permission) {
    logInfo('🔐 Permission Requested: $permission');
  }

  void logPermissionGranted(String permission) {
    logInfo('✅ Permission Granted: $permission');
  }

  void logPermissionDenied(String permission) {
    logWarning('❌ Permission Denied: $permission');
  }

  void logAuthEvent(String event, [dynamic data]) {
    logInfo('🔑 Auth Event: $event', data);
  }

  void logSupabaseEvent(String event, [dynamic data]) {
    logInfo('📦 Supabase Event: $event', data);
  }

  void logNotificationEvent(String event, [dynamic data]) {
    logInfo('🔔 Notification Event: $event', data);
  }

  void logUserAction(String action, [dynamic data]) {
    logInfo('👤 User Action: $action', data);
  }
}
