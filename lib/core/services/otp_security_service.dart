import 'dart:math';

/// Service to handle OTP generation, validation, and security
class OtpSecurityService {
  static const int maxAttempts = 3;
  static const int expiryMinutes = 5;
  static const int otpLength = 6;

  static final Map<String, _OtpData> _otpStore = {};

  /// Generate a secure OTP for the given identifier
  static String generateOtp(String identifier) {
    final random = Random.secure();
    final otp = List.generate(otpLength, (index) => random.nextInt(10)).join();

    final expiry = DateTime.now().add(const Duration(minutes: expiryMinutes));
    _otpStore[identifier] = _OtpData(
      otp: otp,
      expiry: expiry,
      attempts: 0,
      createdAt: DateTime.now(),
    );

    return otp;
  }

  /// Validate OTP for the given identifier
  static OtpValidationResult validateOtp(String identifier, String inputOtp) {
    final otpData = _otpStore[identifier];

    if (otpData == null) {
      return OtpValidationResult.notFound;
    }

    // Check if expired
    if (DateTime.now().isAfter(otpData.expiry)) {
      _otpStore.remove(identifier);
      return OtpValidationResult.expired;
    }

    // Check if maximum attempts exceeded
    if (otpData.attempts >= maxAttempts) {
      _otpStore.remove(identifier);
      return OtpValidationResult.maxAttemptsExceeded;
    }

    // Increment attempts
    otpData.attempts++;

    // Validate OTP
    if (otpData.otp == inputOtp) {
      _otpStore.remove(identifier);
      return OtpValidationResult.valid;
    }

    return OtpValidationResult.invalid;
  }

  /// Check if OTP exists and is still valid for the identifier
  static bool hasValidOtp(String identifier) {
    final otpData = _otpStore[identifier];
    if (otpData == null) return false;

    if (DateTime.now().isAfter(otpData.expiry)) {
      _otpStore.remove(identifier);
      return false;
    }

    return otpData.attempts < maxAttempts;
  }

  /// Get remaining attempts for the identifier
  static int getRemainingAttempts(String identifier) {
    final otpData = _otpStore[identifier];
    if (otpData == null) return 0;

    if (DateTime.now().isAfter(otpData.expiry)) {
      _otpStore.remove(identifier);
      return 0;
    }

    return maxAttempts - otpData.attempts;
  }

  /// Get time remaining until OTP expires
  static Duration? getTimeRemaining(String identifier) {
    final otpData = _otpStore[identifier];
    if (otpData == null) return null;

    final now = DateTime.now();
    if (now.isAfter(otpData.expiry)) {
      _otpStore.remove(identifier);
      return null;
    }

    return otpData.expiry.difference(now);
  }

  /// Clear OTP for the identifier
  static void clearOtp(String identifier) {
    _otpStore.remove(identifier);
  }

  /// Clear all expired OTPs (cleanup method)
  static void clearExpiredOtps() {
    final now = DateTime.now();
    _otpStore.removeWhere((key, value) => now.isAfter(value.expiry));
  }
}

/// Internal class to store OTP data
class _OtpData {
  final String otp;
  final DateTime expiry;
  int attempts;
  final DateTime createdAt;

  _OtpData({
    required this.otp,
    required this.expiry,
    required this.attempts,
    required this.createdAt,
  });
}

/// Enum for OTP validation results
enum OtpValidationResult {
  valid,
  invalid,
  expired,
  notFound,
  maxAttemptsExceeded,
}

/// Extension to get user-friendly messages
extension OtpValidationResultExtension on OtpValidationResult {
  String get message {
    switch (this) {
      case OtpValidationResult.valid:
        return 'تم التحقق بنجاح';
      case OtpValidationResult.invalid:
        return 'رمز التحقق غير صحيح';
      case OtpValidationResult.expired:
        return 'انتهت صلاحية رمز التحقق';
      case OtpValidationResult.notFound:
        return 'لم يتم العثور على رمز التحقق';
      case OtpValidationResult.maxAttemptsExceeded:
        return 'تم تجاوز الحد الأقصى للمحاولات';
    }
  }

  bool get isSuccess => this == OtpValidationResult.valid;
}
