import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing onboarding preferences
class OnboardingPrefs {
  static const String _seenOnboardingKey = 'seenOnboarding';

  /// Check if user has seen onboarding before
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_seenOnboardingKey) ?? false;
    } catch (e) {
      // If error occurs, assume onboarding hasn't been seen
      return false;
    }
  }

  /// Mark onboarding as seen
  static Future<bool> setOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_seenOnboardingKey, true);
    } catch (e) {
      return false;
    }
  }

  /// Reset onboarding preference (for testing/debugging)
  static Future<bool> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_seenOnboardingKey);
    } catch (e) {
      return false;
    }
  }
}
