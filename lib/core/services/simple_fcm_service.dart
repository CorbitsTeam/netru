import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/user_data_helper.dart';
import 'logger_service.dart';

class SimpleFcmService {
  static final SimpleFcmService _instance = SimpleFcmService._internal();
  factory SimpleFcmService() => _instance;
  SimpleFcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LoggerService _logger = LoggerService();
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _cachedToken;

  /// Get FCM token and register it directly with database
  Future<String?> getFcmTokenAndRegister() async {
    try {
      // Request permission first
      await _requestPermission();

      // Get the token
      final token = await _firebaseMessaging.getToken();

      if (token != null) {
        _cachedToken = token;
        _logger.logInfo('✅ FCM Token received: ${token.substring(0, 20)}...');

        // Register directly with database (bypass RLS)
        await _registerTokenDirectly(token);
      } else {
        _logger.logWarning('⚠️ FCM Token is null');
      }

      return token;
    } catch (e) {
      _logger.logError('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get cached token
  String? getCachedToken() => _cachedToken;

  /// Request notification permissions
  Future<bool> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.logInfo(
        '📱 Notification permission: ${settings.authorizationStatus}',
      );
      return isAuthorized;
    } catch (e) {
      _logger.logError('❌ Error requesting permission: $e');
      return false;
    }
  }

  /// Register FCM token directly with database (handling upsert logic)
  Future<void> _registerTokenDirectly(String token) async {
    try {
      // Get current user
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      if (currentUser == null || currentUser.id == null) {
        _logger.logWarning('⚠️ No user logged in, skipping token registration');
        return;
      }

      _logger.logInfo('🔍 Registering FCM token for user: ${currentUser.id}');

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      // First strategy: Try RPC function first (most reliable)
      bool rpcSuccess = false;
      try {
        await _supabase.rpc(
          'upsert_fcm_token_str',
          params: {
            'p_user_id': currentUser.id!,
            'p_fcm_token': token,
            'p_device_type': _getDeviceTypeString(),
            'p_device_id': deviceInfo,
            'p_app_version': packageInfo.version,
          },
        );
        rpcSuccess = true;
        _logger.logInfo('✅ FCM token upserted via RPC function successfully');
        return;
      } catch (rpcError) {
        _logger.logInfo(
          '⚠️ RPC upsert failed, trying direct database access: $rpcError',
        );
      }

      // Second strategy: Direct database upsert if RPC failed
      if (!rpcSuccess) {
        try {
          // Try to update existing token first
          final updateResult =
              await _supabase
                  .from('user_fcm_tokens')
                  .update({
                    'fcm_token': token,
                    'is_active': true,
                    'last_used': DateTime.now().toIso8601String(),
                    'app_version': packageInfo.version,
                  })
                  .eq('user_id', currentUser.id!)
                  .eq('device_type', _getDeviceTypeString())
                  .select();

          if (updateResult.isNotEmpty) {
            _logger.logInfo('✅ Existing FCM token updated successfully');
            return;
          }

          // If no rows updated, try insert
          await _supabase.from('user_fcm_tokens').insert({
            'user_id': currentUser.id,
            'fcm_token': token,
            'device_type': _getDeviceTypeString(),
            'device_id': deviceInfo,
            'app_version': packageInfo.version,
            'is_active': true,
            'last_used': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });

          _logger.logInfo('✅ New FCM token inserted successfully');
          return;
        } catch (dbError) {
          _logger.logWarning('⚠️ Direct database access failed: $dbError');
        }
      }

      // Third strategy: Store locally as fallback
      _logger.logInfo('📱 Storing FCM token locally as fallback');
      await _storeTokenLocally(
        token,
        currentUser.id!,
        deviceInfo,
        packageInfo.version,
      );
    } catch (e) {
      final userHelper = UserDataHelper();
      final user = userHelper.getCurrentUser();
      _logger.logError('❌ All FCM token registration methods failed: $e');
      _logger.logError('   User ID: ${user?.id}');
      _logger.logError('   Token: ${token.substring(0, 20)}...');

      // Final fallback - store locally
      if (user?.id != null) {
        await _storeTokenLocally(token, user!.id!, '', '');
      }
    }
  }

  /// Store FCM token locally as fallback when database operations fail
  Future<void> _storeTokenLocally(
    String token,
    String userId,
    String deviceId,
    String appVersion,
  ) async {
    try {
      // Store in SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token_$userId', token);
      await prefs.setString('fcm_token_device_id_$userId', deviceId);
      await prefs.setString('fcm_token_app_version_$userId', appVersion);
      await prefs.setString(
        'fcm_token_timestamp_$userId',
        DateTime.now().toIso8601String(),
      );

      _logger.logInfo('✅ FCM token stored locally as fallback');
      _logger.logInfo('💡 Token will be retried on next app start');

      // Schedule retry for later (could be implemented)
      _scheduleRetry(token);
    } catch (e) {
      _logger.logError('❌ Failed to store FCM token locally: $e');
    }
  }

  /// Schedule a retry to register the token later
  void _scheduleRetry(String token) {
    // Simple retry mechanism - try again after 30 seconds
    Timer(const Duration(seconds: 30), () {
      _logger.logInfo('🔄 Retrying FCM token registration...');
      _registerTokenDirectly(token);
    });
  }

  /// Get device type as string
  String _getDeviceTypeString() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android'; // Default fallback
  }

  /// Get device ID/info
  Future<String> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return 'android_device_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        return 'ios_device_${DateTime.now().millisecondsSinceEpoch}';
      }

      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _logger.logError('❌ Error getting device info: $e');
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Set up token refresh listener
  void setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _logger.logInfo(
        '🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...',
      );
      _cachedToken = newToken;
      _registerTokenDirectly(newToken);
    });
  }

  /// Retry sending locally stored tokens
  Future<void> retryLocalTokens() async {
    try {
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      if (currentUser?.id == null) return;

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('fcm_token_${currentUser!.id}');

      if (storedToken != null) {
        _logger.logInfo(
          '🔄 Found locally stored FCM token, attempting to sync...',
        );
        await _registerTokenDirectly(storedToken);

        // If successful, remove from local storage
        await prefs.remove('fcm_token_${currentUser.id}');
        await prefs.remove('fcm_token_device_id_${currentUser.id}');
        await prefs.remove('fcm_token_app_version_${currentUser.id}');
        await prefs.remove('fcm_token_timestamp_${currentUser.id}');

        _logger.logInfo('🧹 Cleaned up local FCM token storage');
      }
    } catch (e) {
      _logger.logError('❌ Failed to retry local tokens: $e');
    }
  }

  /// Initialize the service
  Future<void> init() async {
    try {
      _logger.logInfo('🚀 Initializing SimpleFcmService...');

      // First, try to sync any locally stored tokens
      await retryLocalTokens();

      // Get and register FCM token
      await getFcmTokenAndRegister();

      // Setup token refresh listener
      setupTokenRefreshListener();

      _logger.logInfo('✅ SimpleFcmService initialized successfully');
    } catch (e) {
      _logger.logError('❌ SimpleFcmService initialization failed: $e');
    }
  }
}
