/// Utility class for parsing and validating Egyptian National IDs
class EgyptianIdParser {
  /// Parses Egyptian national ID to extract date of birth
  ///
  /// Egyptian national ID format: XYYMMDDGGGGC
  /// X: Century code (2 = 1900s, 3 = 2000s)
  /// YY: Year (last two digits)
  /// MM: Month (01-12)
  /// DD: Day (01-31)
  /// GGGG: Governorate and sequence number
  /// C: Check digit
  static DateTime? parseEgyptianNationalIdToDOB(String id14) {
    if (id14.length != 14) return null;

    final centuryCode = int.tryParse(id14[0]);
    final yearPart = int.tryParse(id14.substring(1, 3));
    final month = int.tryParse(id14.substring(3, 5));
    final day = int.tryParse(id14.substring(5, 7));

    if (centuryCode == null ||
        yearPart == null ||
        month == null ||
        day == null) {
      return null;
    }

    int year;
    if (centuryCode == 2) {
      year = 1900 + yearPart;
    } else if (centuryCode == 3) {
      year = 2000 + yearPart;
    } else {
      return null;
    }

    try {
      final dob = DateTime(year, month, day);

      // Basic sanity check: year must be reasonable
      if (dob.year < 1900 || dob.year > DateTime.now().year) {
        return null;
      }

      // Check if the date is in the future
      if (dob.isAfter(DateTime.now())) {
        return null;
      }

      return dob;
    } catch (e) {
      return null;
    }
  }

  /// Validates Egyptian national ID format
  static bool isValidEgyptianNationalId(String id) {
    if (id.length != 14) return false;

    // Check if all characters are digits
    if (!RegExp(r'^\d{14}$').hasMatch(id)) return false;

    // Check century code (first digit should be 2 or 3)
    final centuryCode = int.parse(id[0]);
    if (centuryCode != 2 && centuryCode != 3) return false;

    // Check month (positions 3-4, should be 01-12)
    final month = int.parse(id.substring(3, 5));
    if (month < 1 || month > 12) return false;

    // Check day (positions 5-6, should be 01-31)
    final day = int.parse(id.substring(5, 7));
    if (day < 1 || day > 31) return false;

    // Try to parse the date to ensure it's valid
    final dob = parseEgyptianNationalIdToDOB(id);
    return dob != null;
  }

  /// Extracts governorate code from national ID
  static String? getGovernorateCode(String id14) {
    if (!isValidEgyptianNationalId(id14)) return null;
    return id14.substring(7, 9);
  }

  /// Determines gender from national ID
  /// (9th digit from right: odd = male, even = female)
  static String? getGender(String id14) {
    if (!isValidEgyptianNationalId(id14)) return null;

    final genderDigit = int.parse(id14[12]);
    return genderDigit % 2 == 1 ? 'male' : 'female';
  }
}
