import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseSetupHelper {
  static final _supabase = Supabase.instance.client;

  static Future<void> insertTestNotifications(String userId) async {
    try {
      debugPrint('Creating test notifications for user: $userId');

      final notifications = [
        {
          'user_id': userId,
          'title': 'مرحباً بك في نترو',
          'title_ar': 'مرحباً بك في نترو',
          'body': 'مرحباً بك في تطبيق نترو. يمكنك الآن تقديم ومتابعة البلاغات.',
          'body_ar':
              'مرحباً بك في تطبيق نترو. يمكنك الآن تقديم ومتابعة البلاغات.',
          'notification_type': 'system',
          'is_read': false,
          'priority': 'normal',
        },
        {
          'user_id': userId,
          'title': 'تم تقديم البلاغ بنجاح',
          'title_ar': 'تم تقديم البلاغ بنجاح',
          'body': 'تم تقديم بلاغك وهو الآن قيد المراجعة.',
          'body_ar': 'تم تقديم بلاغك وهو الآن قيد المراجعة.',
          'notification_type': 'report_update',
          'is_read': false,
          'priority': 'normal',
        },
      ];

      try {
        await _supabase.from('notifications').insert(notifications);
        debugPrint('✅ Test notifications created successfully');
      } catch (e) {
        debugPrint('❌ Failed to create notifications: $e');
      }
    } catch (e) {
      debugPrint('Error in insertTestNotifications: $e');
    }
  }

  static Future<void> testNotifications(String userId) async {
    try {
      final notifications = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId);

      debugPrint('Found ${notifications.length} notifications');

      if (notifications.isEmpty) {
        await insertTestNotifications(userId);
      }
    } catch (e) {
      debugPrint('Error testing notifications: $e');
    }
  }

  /// Complete setup and test - creates test notifications if none exist
  static Future<void> completeSetup(String userId) async {
    try {
      debugPrint('🚀 Starting notification system setup for user: $userId');

      // Check if user has any notifications
      final existing = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existing.isEmpty) {
        debugPrint('📝 No notifications found, creating test data...');
        await insertTestNotifications(userId);
      } else {
        debugPrint('ℹ️ User already has notifications');
      }

      debugPrint('✅ Notification system setup completed successfully!');
    } catch (e) {
      debugPrint('❌ Error in completeSetup: $e');
      // Don't throw - let the app continue even if setup fails
    }
  }
}
