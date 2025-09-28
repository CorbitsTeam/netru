import 'dart:math';

/// Utility class for input sanitization and security
class SecurityUtils {
  /// Sanitize user input to prevent XSS and injection attacks
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(
          RegExp(r'[<>&"\x27`]'),
          '',
        ) // Remove potentially dangerous characters
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Sanitize email input
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase().replaceAll(RegExp(r'[<>&"\x27`]'), '');
  }

  /// Sanitize phone number (keep only digits and + sign)
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitize name (allow Arabic, English letters, spaces, and common name characters)
  static String sanitizeName(String name) {
    return name
        .trim()
        .replaceAll(
          RegExp(r'[<>&"\x270-9`]'),
          '',
        ) // Remove dangerous chars and numbers
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Generate a secure random password
  static String generateSecurePassword({int length = 12}) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyz'
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        '0123456789'
        '!@#\$%^&*';

    final random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Validate if a string contains only safe characters
  static bool isSafeInput(String input) {
    // Check for potentially dangerous patterns
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'data:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }

    return true;
  }

  /// Check if email domain is potentially suspicious
  static bool isSuspiciousEmailDomain(String email) {
    final domain = email.split('@').last.toLowerCase();

    // List of commonly used temporary/disposable email domains
    const suspiciousDomains = [
      '10minutemail.com',
      'tempmail.org',
      'guerrillamail.com',
      'mailinator.com',
      'throwaway.email',
    ];

    return suspiciousDomains.contains(domain);
  }

  /// Normalize and validate Egyptian phone numbers
  static String? normalizeEgyptianPhone(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different Egyptian phone formats
    if (digitsOnly.startsWith('2010') ||
        digitsOnly.startsWith('2011') ||
        digitsOnly.startsWith('2012') ||
        digitsOnly.startsWith('2015')) {
      // Remove country code if present
      digitsOnly = digitsOnly.substring(2);
    }

    // Ensure it starts with 01 and has correct length
    if (digitsOnly.startsWith('01') && digitsOnly.length == 11) {
      return digitsOnly;
    }

    return null; // Invalid format
  }

  /// Validate password strength and return issues
  static List<String> getPasswordIssues(String password) {
    final issues = <String>[];

    if (password.length < 8) {
      issues.add('يجب أن تكون 8 أحرف على الأقل');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      issues.add('يجب أن تحتوي على حرف صغير');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      issues.add('يجب أن تحتوي على حرف كبير');
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      issues.add('يجب أن تحتوي على رقم');
    }

    // Check for common weak passwords
    const commonPasswords = [
      'password',
      '12345678',
      'qwerty123',
      'admin123',
      'user1234',
    ];

    if (commonPasswords.contains(password.toLowerCase())) {
      issues.add('كلمة مرور شائعة جداً');
    }

    return issues;
  }
}
