import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routing/routes.dart';
import '../services/logger_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _logger = LoggerService();
  late NavigatorState _navigator;
  StreamSubscription<String>? _linkSubscription;

  // Initialize deep linking
  void init(NavigatorState navigator) {
    _navigator = navigator;
    _logger.logInfo('🔗 DeepLinkService initialized');
  }

  // Handle incoming deep links
  Future<void> handleDeepLink(String link) async {
    try {
      _logger.logInfo('🔗 Handling deep link: $link');
      final uri = Uri.parse(link);

      if (uri.scheme == 'netru') {
        await _handleNetruScheme(uri);
      }
    } catch (e) {
      _logger.logError('❌ Error handling deep link: $e');
    }
  }

  // Handle netru:// scheme links
  Future<void> _handleNetruScheme(Uri uri) async {
    switch (uri.host) {
      case 'login':
        await _handleLoginDeepLink(uri);
        break;
      case 'password-reset':
        await _handlePasswordResetDeepLink(uri);
        break;
      default:
        _logger.logWarning('⚠️ Unknown deep link host: ${uri.host}');
        // Default to home screen
        _navigator.pushNamedAndRemoveUntil(
          Routes.customBottomBar,
          (route) => false,
        );
        break;
    }
  }

  // Handle login deep links
  Future<void> _handleLoginDeepLink(Uri uri) async {
    final queryParams = uri.queryParameters;

    // Check if this is a password reset success callback
    if (queryParams.containsKey('password_reset') &&
        queryParams['password_reset'] == 'success') {
      _logger.logInfo('✅ Password reset successful - navigating to login');

      // Navigate to login screen and show success message
      _navigator.pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);

      // Show success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (_navigator.context.mounted) {
        ScaffoldMessenger.of(_navigator.context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تغيير كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
              style: TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Regular login navigation
      _navigator.pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
    }
  }

  // Handle password reset deep links
  Future<void> _handlePasswordResetDeepLink(Uri uri) async {
    _logger.logInfo('🔐 Password reset deep link received');
    _navigator.pushNamedAndRemoveUntil(
      Routes.forgotPasswordScreen,
      (route) => false,
    );
  }

  // Open external URL
  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _logger.logError('❌ Cannot launch URL: $url');
      }
    } catch (e) {
      _logger.logError('❌ Error launching URL: $e');
    }
  }

  // Clean up
  void dispose() {
    _linkSubscription?.cancel();
  }
}
