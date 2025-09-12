import 'egyptian_id_parser.dart';

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

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  /// Validates email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Validates phone number (Egyptian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Egyptian mobile number format: 01xxxxxxxxx (11 digits starting with 01)
    if (!RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 01 ويحتوي على 11 رقم)';
    }

    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (value.length > 100) {
      return 'الاسم طويل جداً';
    }

    // Allow Arabic and English letters, spaces, and common name characters
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s\-\.]+$').hasMatch(value)) {
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
