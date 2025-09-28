import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle cleanup and recovery for failed registrations
class SignupRecoveryService {
  static final _supabase = Supabase.instance.client;

  /// Clean up failed registration data
  static Future<void> cleanupFailedRegistration(String userId) async {
    try {
      print('🧹 Starting cleanup for user: $userId');

      // Remove from users table
      await _supabase.from('users').delete().eq('id', userId);
      print('✅ Removed user from users table');

      // Remove uploaded documents if any
      try {
        await _supabase.storage.from('documents').remove(['user_$userId/']);
        print('✅ Removed user documents');
      } catch (e) {
        print('⚠️ No documents to remove or error removing documents: $e');
      }

      print('✅ Cleanup completed for user: $userId');
    } catch (e) {
      print('❌ Cleanup failed for user $userId: $e');
      // Don't throw here as this is a cleanup operation
    }
  }

  /// Clean up partial registration when OTP verification fails
  static Future<void> cleanupPartialRegistration(String identifier) async {
    try {
      print('🧹 Starting partial cleanup for identifier: $identifier');

      // Try to find and remove user by email or phone
      final userByEmail =
          await _supabase
              .from('users')
              .select('id')
              .eq('email', identifier)
              .maybeSingle();

      if (userByEmail != null) {
        await cleanupFailedRegistration(userByEmail['id']);
        return;
      }

      final userByPhone =
          await _supabase
              .from('users')
              .select('id')
              .eq('phone', identifier)
              .maybeSingle();

      if (userByPhone != null) {
        await cleanupFailedRegistration(userByPhone['id']);
        return;
      }

      print('ℹ️ No partial registration found for cleanup');
    } catch (e) {
      print('❌ Partial cleanup failed: $e');
    }
  }

  /// Check if a user registration is incomplete and clean it up
  static Future<void> cleanupIncompleteRegistrations() async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));

      // Find users created more than 24 hours ago with pending verification
      final incompleteUsers = await _supabase
          .from('users')
          .select('id, created_at')
          .eq('verification_status', 'pending')
          .lt('created_at', oneDayAgo.toIso8601String());

      for (final user in incompleteUsers) {
        await cleanupFailedRegistration(user['id']);
        print('🧹 Cleaned up incomplete registration: ${user['id']}');
      }
    } catch (e) {
      print('❌ Bulk cleanup failed: $e');
    }
  }

  /// Validate and recover from inconsistent auth state
  static Future<bool> validateAuthConsistency(String email) async {
    try {
      // Check if user exists in our database
      final userInDb =
          await _supabase
              .from('users')
              .select('id')
              .eq('email', email)
              .maybeSingle();

      // Check current auth user
      final currentAuthUser = _supabase.auth.currentUser;

      // If user exists in DB but no auth session, there's an inconsistency
      if (userInDb != null && currentAuthUser == null) {
        print('⚠️ Found user in DB without auth session');
        return false;
      }

      // If auth session exists but no user in DB, there's an inconsistency
      if (currentAuthUser != null && userInDb == null) {
        print('⚠️ Found auth session without user in DB');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Auth consistency check failed: $e');
      return false;
    }
  }

  /// Attempt to recover from auth inconsistency
  static Future<void> recoverFromAuthInconsistency(String email) async {
    try {
      // Sign out current session if any
      await _supabase.auth.signOut();
      print('🔄 Signed out inconsistent auth session');

      // Clear any partial data
      await cleanupPartialRegistration(email);
      print('🧹 Cleared partial registration data');
    } catch (e) {
      print('❌ Recovery from auth inconsistency failed: $e');
    }
  }
}
