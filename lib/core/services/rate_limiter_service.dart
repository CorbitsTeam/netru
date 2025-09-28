/// Service to handle rate limiting for various operations
class RateLimiterService {
  static final Map<String, List<DateTime>> _attempts = {};
  static const int maxSignupAttempts = 5;
  static const int maxOtpAttempts = 3;
  static const int windowMinutes = 15;
  static const int otpWindowMinutes = 5;

  /// Check if signup attempt is allowed for given identifier
  static bool canAttemptSignup(String identifier) {
    return _canAttempt(
      identifier,
      'signup_$identifier',
      maxSignupAttempts,
      windowMinutes,
    );
  }

  /// Record a signup attempt for given identifier
  static void recordSignupAttempt(String identifier) {
    _recordAttempt('signup_$identifier');
  }

  /// Check if OTP request is allowed for given identifier
  static bool canRequestOtp(String identifier) {
    return _canAttempt(
      identifier,
      'otp_$identifier',
      maxOtpAttempts,
      otpWindowMinutes,
    );
  }

  /// Record an OTP request for given identifier
  static void recordOtpRequest(String identifier) {
    _recordAttempt('otp_$identifier');
  }

  /// Generic method to check if attempt is allowed
  static bool _canAttempt(
    String identifier,
    String key,
    int maxAttempts,
    int windowMinutes,
  ) {
    final now = DateTime.now();
    final attempts = _attempts[key] ?? [];

    // Remove old attempts outside the time window
    attempts.removeWhere(
      (time) => now.difference(time).inMinutes > windowMinutes,
    );

    _attempts[key] = attempts;

    return attempts.length < maxAttempts;
  }

  /// Generic method to record an attempt
  static void _recordAttempt(String key) {
    final attempts = _attempts[key] ?? [];
    attempts.add(DateTime.now());
    _attempts[key] = attempts;
  }

  /// Clear all attempts for a given identifier (useful after successful completion)
  static void clearAttempts(String identifier) {
    _attempts.removeWhere((key, value) => key.contains(identifier));
  }

  /// Get remaining attempts for signup
  static int getRemainingSignupAttempts(String identifier) {
    final key = 'signup_$identifier';
    final now = DateTime.now();
    final attempts = _attempts[key] ?? [];

    // Remove old attempts
    attempts.removeWhere(
      (time) => now.difference(time).inMinutes > windowMinutes,
    );

    return maxSignupAttempts - attempts.length;
  }

  /// Get time until next attempt is allowed
  static Duration? getTimeUntilNextAttempt(
    String identifier, {
    bool isOtp = false,
  }) {
    final key = isOtp ? 'otp_$identifier' : 'signup_$identifier';
    final windowMins = isOtp ? otpWindowMinutes : windowMinutes;
    final maxAttempts = isOtp ? maxOtpAttempts : maxSignupAttempts;

    final attempts = _attempts[key] ?? [];
    if (attempts.length < maxAttempts) return null;

    final oldestAttempt = attempts.first;
    final nextAllowedTime = oldestAttempt.add(Duration(minutes: windowMins));
    final now = DateTime.now();

    if (now.isBefore(nextAllowedTime)) {
      return nextAllowedTime.difference(now);
    }

    return null;
  }
}
