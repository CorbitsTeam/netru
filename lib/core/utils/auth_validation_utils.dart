import 'egyptian_id_parser.dart';
import 'security_utils.dart';

/// Utility class for form validation
class AuthValidationUtils {
  /// Validates Egyptian national ID
  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرقم القومي مطلوب';
    }

    if (value.length != 14) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }

    if (!RegExp(r'^\d{14}$').hasMatch(value)) {
      return 'الرقم القومي يجب أن يحتوي على أرقام فقط';
    }

    // Additional validation using Egyptian ID parser
    final isValid = EgyptianIdParser.isValidEgyptianNationalId(value);
    if (!isValid) {
      return 'الرقم القومي غير صحيح';
    }

    return null;
  }

  /// Validates passport number
  static String? validatePassportNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الجواز مطلوب';
    }

    if (value.length < 6 || value.length > 12) {
      return 'رقم الجواز يجب أن يكون بين 6-12 حرف أو رقم';
    }

    // Allow alphanumeric characters
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'رقم الجواز يجب أن يحتوي على أحرف وأرقام فقط';
    }

    return null;
  }

  /// Validates password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    // Check for comprehensive password issues
    final issues = SecurityUtils.getPasswordIssues(value);
    if (issues.isNotEmpty) {
      return issues.first; // Return first issue found
    }

    return null;
  }

  /// Validates email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    // Sanitize input first
    final cleanEmail = SecurityUtils.sanitizeEmail(value);

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    // Check for suspicious domains
    if (SecurityUtils.isSuspiciousEmailDomain(cleanEmail)) {
      return 'يرجى استخدام بريد إلكتروني صحيح';
    }

    return null;
  }

  /// Validates phone number (Egyptian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Normalize and validate Egyptian phone
    final normalizedPhone = SecurityUtils.normalizeEgyptianPhone(value);
    if (normalizedPhone == null) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 01 ويحتوي على 11 رقم)';
    }

    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }

    // Sanitize input first
    final cleanName = SecurityUtils.sanitizeName(value);

    if (cleanName.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (cleanName.length > 100) {
      return 'الاسم طويل جداً';
    }

    // Allow Arabic and English letters, spaces, and common name characters
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s\-\.]+$').hasMatch(cleanName)) {
      return 'الاسم يحتوي على أحرف غير مسموحة';
    }

    // Check if input is safe
    if (!SecurityUtils.isSafeInput(value)) {
      return 'الاسم يحتوي على أحرف غير مسموحة';
    }

    return null;
  }

  /// Validates address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Address is optional
    }

    if (value.length < 5) {
      return 'العنوان قصير جداً';
    }

    if (value.length > 255) {
      return 'العنوان طويل جداً';
    }

    return null;
  }

  /// Get password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    return score;
  }

  /// Get password strength text
  static String getPasswordStrengthText(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'ضعيف جداً';
      case 2:
        return 'ضعيف';
      case 3:
        return 'متوسط';
      case 4:
        return 'قوي';
      case 5:
        return 'قوي جداً';
      default:
        return 'ضعيف جداً';
    }
  }
}
