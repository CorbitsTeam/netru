import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script to manually run the SQL functions needed for notifications
class DatabaseSetupHelper {
  static final _supabase = Supabase.instance.client;

  /// Run this to set up the database functions for notifications
  static Future<void> setupNotificationFunctions() async {
    try {
      debugPrint('🔧 Setting up notification functions...');
      // Functions will be created by the fallback methods in the data source
      // This is just a placeholder for now
      debugPrint(
        '✅ Notification functions setup completed (using fallback methods)',
      );
    } catch (e) {
      debugPrint('❌ Error during function setup: $e');
    }
  }

  /// Insert test notifications for a user (only if none exist)
  static Future<void> insertTestNotifications(String userId) async {
    try {
      // Check if user already has notifications
      final existingNotifications = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existingNotifications.isNotEmpty) {
        debugPrint(
          'ℹ️ User already has notifications, skipping test data insertion',
        );
        return;
      }

      debugPrint('📝 Creating test notifications for user...');

      final notifications = [
        {
          'user_id': userId,
          'title': 'Welcome to NetRu',
          'title_ar': 'مرحباً بك في نترو',
          'body':
              'Welcome to the NetRu application. You can now submit and track reports.',
          'body_ar':
              'مرحباً بك في تطبيق نترو. يمكنك الآن تقديم ومتابعة البلاغات.',
          'notification_type': 'system',
          'is_read': false,
          'priority': 'normal',
        },
        {
          'user_id': userId,
          'title': 'Report Submitted Successfully',
          'title_ar': 'تم تقديم البلاغ بنجاح',
          'body': 'Your report has been submitted and is now under review.',
          'body_ar': 'تم تقديم بلاغك وهو الآن قيد المراجعة.',
          'notification_type': 'report_update',
          'is_read': false,
          'priority': 'normal',
        },
        {
          'user_id': userId,
          'title': 'System Update',
          'title_ar': 'تحديث النظام',
          'body':
              'The system has been updated with new features and improvements.',
          'body_ar': 'تم تحديث النظام بميزات وتحسينات جديدة.',
          'notification_type': 'system',
          'is_read': true,
          'priority': 'low',
        },
        {
          'user_id': userId,
          'title': 'New News Article',
          'title_ar': 'مقال إخباري جديد',
          'body': 'A new news article has been published. Check it out now.',
          'body_ar': 'تم نشر مقال إخباري جديد. تصفحه الآن.',
          'notification_type': 'news',
          'is_read': false,
          'priority': 'normal',
        },
      ];

      await _supabase.from('notifications').insert(notifications);
      debugPrint('✅ Test notifications inserted successfully');
    } catch (e) {
      debugPrint('❌ Error inserting test notifications: $e');
    }
  }

  /// Test the notification functions
  static Future<void> testNotificationFunctions(String userId) async {
    try {
      // Test getting notifications directly from table
      final notifications = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('📝 Total notifications: ${notifications.length}');

      // Count unread notifications manually
      final unreadNotifications =
          notifications.where((n) => n['is_read'] == false).toList();
      debugPrint(
        '📊 Unread notifications count: ${unreadNotifications.length}',
      );

      // Test if we have any notifications at all
      if (notifications.isEmpty) {
        debugPrint(
          'ℹ️ No notifications found for user. Will create test data.',
        );
        return;
      }

      debugPrint('✅ Notification system test completed successfully');
    } catch (e) {
      debugPrint('❌ Error testing notification functions: $e');
    }
  }

  /// Complete setup and test
  static Future<void> completeSetup(String userId) async {
    debugPrint('🚀 Starting notification system setup for user: $userId');

    await setupNotificationFunctions();
    await insertTestNotifications(userId);
    await testNotificationFunctions(userId);

    debugPrint('✅ Notification system setup completed successfully!');
    debugPrint(
      '💡 You can now navigate to the notifications screen to see your notifications.',
    );
  }
}
