class ValidationHelper {
  // Validate Name Fields (First Name, Last Name)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون أكثر من حرف واحد';
    }

    // Check if contains only Arabic letters and spaces
    final arabicRegex = RegExp(
      r'^[\u0600-\u06FF\s]+$',
    );
    if (!arabicRegex.hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على أحرف عربية فقط';
    }

    return null;
  }

  // Validate National ID (14 digits)
  static String? validateNationalId(
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم القومي مطلوب';
    }

    if (value.trim().length != 14) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }

    // Check if contains only digits
    final digitRegex = RegExp(r'^[0-9]+$');
    if (!digitRegex.hasMatch(value.trim())) {
      return 'الرقم القومي يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // Validate Phone Number (11 digits)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    if (value.trim().length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }

    // Check if contains only digits
    final digitRegex = RegExp(r'^[0-9]+$');
    if (!digitRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }

    // Check if starts with 01 (Egyptian mobile numbers)
    if (!value.trim().startsWith('01')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 01';
    }

    return null;
  }

  // Validate Report Type
  static String? validateReportType(
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'نوع البلاغ مطلوب';
    }

    return null;
  }

  // Validate Location
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الموقع الجغرافي مطلوب';
    }

    return null;
  }

  // Validate Date Time
  static String? validateDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'التاريخ والوقت مطلوب';
    }

    return null;
  }

  // Validate Report Details (Optional field)
  static String? validateReportDetails(
    String? value,
  ) {
    // This field is optional, so return null if empty
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // If provided, check minimum length
    if (value.trim().length < 10) {
      return 'تفاصيل البلاغ يجب أن تكون أكثر من 10 أحرف';
    }

    return null;
  }

  // Validate Email (if needed in future)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Check if string contains only Arabic characters
  static bool isArabic(String text) {
    final arabicRegex = RegExp(
      r'^[\u0600-\u06FF\s]+',
    );
    return arabicRegex.hasMatch(text);
  }

  // Check if string contains only digits
  static bool isNumeric(String text) {
    final digitRegex = RegExp(r'^[0-9]+');
    return digitRegex.hasMatch(text);
  }

  // Format phone number for display (if needed)
  static String formatPhoneNumber(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }

  // Format national ID for display (if needed)
  static String formatNationalId(
    String nationalId,
  ) {
    if (nationalId.length == 14) {
      return '${nationalId.substring(0, 1)} ${nationalId.substring(1, 3)} ${nationalId.substring(3, 5)} ${nationalId.substring(5, 7)} ${nationalId.substring(7, 12)} ${nationalId.substring(12)}';
    }
    return nationalId;
  }
}
