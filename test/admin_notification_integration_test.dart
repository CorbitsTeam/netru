import 'package:flutter_test/flutter_test.dart';
import 'package:netru_app/features/admin/data/models/admin_notification_model.dart';
import 'package:netru_app/features/admin/domain/entities/admin_notification_entity.dart';

void main() {
  group('AdminNotificationModel Tests', () {
    test('should create AdminNotificationModel from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'user_id': 'admin',
        'title': 'Test Notification',
        'body': 'Test Body',
        'notification_type': 'general',
        'is_read': false,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.id, '1');
      expect(notification.userId, 'admin');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'Test Body');
      expect(notification.notificationType, NotificationType.general);
      expect(notification.isRead, false);
      expect(notification.isSent, true);
      expect(notification.priority, NotificationPriority.normal);
      expect(notification.createdAt, isA<DateTime>());
    });

    test('should handle JSON with missing optional fields', () {
      // Arrange
      final json = {
        'id': '2',
        'user_id': 'user123',
        'title': 'Simple Notification',
        'body': 'Simple Body',
        'notification_type': 'announcement',
        'is_read': false,
        'is_sent': false,
        'priority': 'high',
        'created_at': '2024-01-01T00:00:00Z',
        // Missing optional fields like userName, data, etc.
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.id, '2');
      expect(notification.userId, 'user123');
      expect(notification.title, 'Simple Notification');
      expect(notification.userName, isNull);
      expect(notification.data, isNull);
      expect(notification.referenceId, isNull);
      expect(notification.referenceType, isNull);
    });

    test('should handle different notification types', () {
      final types = [
        {'string': 'general', 'enum': NotificationType.general},
        {'string': 'news', 'enum': NotificationType.news},
        {'string': 'system', 'enum': NotificationType.system},
        {'string': 'report_update', 'enum': NotificationType.reportUpdate},
        {'string': 'report_comment', 'enum': NotificationType.reportComment},
      ];

      for (final type in types) {
        // Arrange
        final json = {
          'id': 'test_${type['string']}',
          'user_id': 'admin',
          'title': 'Test ${type['string']}',
          'body': 'Test Body for ${type['string']}',
          'notification_type': type['string'],
          'is_read': false,
          'is_sent': true,
          'priority': 'normal',
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final notification = AdminNotificationModel.fromJson(json);

        // Assert
        expect(notification.notificationType, type['enum']);
        expect(notification.title, 'Test ${type['string']}');
      }
    });

    test('should handle different priority levels', () {
      final priorities = [
        {'string': 'low', 'enum': NotificationPriority.low},
        {'string': 'normal', 'enum': NotificationPriority.normal},
        {'string': 'high', 'enum': NotificationPriority.high},
        {'string': 'urgent', 'enum': NotificationPriority.urgent},
      ];

      for (final priority in priorities) {
        // Arrange
        final json = {
          'id': 'test_${priority['string']}',
          'user_id': 'admin',
          'title': 'Test Priority',
          'body': 'Test Body',
          'notification_type': 'general',
          'is_read': false,
          'is_sent': true,
          'priority': priority['string'],
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final notification = AdminNotificationModel.fromJson(json);

        // Assert
        expect(notification.priority, priority['enum']);
      }
    });

    test('should handle read and sent status correctly', () {
      // Test combinations of isRead and isSent
      final statusCombinations = [
        {'is_read': true, 'is_sent': true},
        {'is_read': true, 'is_sent': false},
        {'is_read': false, 'is_sent': true},
        {'is_read': false, 'is_sent': false},
      ];

      for (final status in statusCombinations) {
        // Arrange
        final json = {
          'id': 'test_status',
          'user_id': 'admin',
          'title': 'Status Test',
          'body': 'Status Body',
          'notification_type': 'general',
          'priority': 'normal',
          'created_at': '2024-01-01T00:00:00Z',
          ...status,
        };

        // Act
        final notification = AdminNotificationModel.fromJson(json);

        // Assert
        expect(notification.isRead, status['is_read']);
        expect(notification.isSent, status['is_sent']);
      }
    });

    test('should handle additional data field', () {
      // Arrange
      final json = {
        'id': '3',
        'user_id': 'user789',
        'title': 'Data Test',
        'body': 'Test with data',
        'notification_type': 'report_update',
        'is_read': false,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
        'data': {
          'case_number': 'CASE123',
          'status': 'in_progress',
          'location': 'Cairo',
        },
        'reference_id': 'REF456',
        'reference_type': 'report',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.data, isA<Map<String, dynamic>>());
      expect(notification.data!['case_number'], 'CASE123');
      expect(notification.data!['status'], 'in_progress');
      expect(notification.data!['location'], 'Cairo');
      expect(notification.referenceId, 'REF456');
      expect(notification.referenceType, ReferenceType.report);
    });

    test('should handle userName from users join', () {
      // Arrange
      final json = {
        'id': '4',
        'user_id': 'user456',
        'user_name': 'أحمد محمد', // Arabic name
        'title': 'User Test',
        'body': 'Test with user name',
        'notification_type': 'general',
        'is_read': true,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.userName, 'أحمد محمد');
    });

    test('should handle timestamps correctly', () {
      // Arrange
      final json = {
        'id': '5',
        'user_id': 'admin',
        'title': 'Timestamp Test',
        'body': 'Test timestamps',
        'notification_type': 'general',
        'is_read': true,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T10:30:00Z',
        'read_at': '2024-01-01T11:00:00Z',
        'sent_at': '2024-01-01T10:30:00Z',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.createdAt, isA<DateTime>());
      expect(notification.readAt, isA<DateTime>());
      expect(notification.sentAt, isA<DateTime>());

      // Verify specific timestamps
      expect(notification.createdAt.hour, 10);
      expect(notification.createdAt.minute, 30);
      expect(notification.readAt!.hour, 11);
      expect(notification.readAt!.minute, 0);
    });
  });

  group('AdminNotificationModel Edge Cases', () {
    test('should handle null values gracefully', () {
      // Arrange
      final json = {
        'id': '6',
        'user_id': 'admin',
        'title': 'Null Test',
        'body': 'Test null handling',
        'notification_type': 'general',
        'is_read': false,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
        'user_name': null,
        'data': null,
        'reference_id': null,
        'reference_type': null,
        'read_at': null,
        'sent_at': null,
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.userName, isNull);
      expect(notification.data, isNull);
      expect(notification.referenceId, isNull);
      expect(notification.referenceType, isNull);
      expect(notification.readAt, isNull);
      expect(notification.sentAt, isNull);
    });

    test('should handle empty strings', () {
      // Arrange
      final json = {
        'id': '7',
        'user_id': 'admin',
        'title': '', // Empty title
        'body': '', // Empty body
        'notification_type': 'general',
        'is_read': false,
        'is_sent': true,
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
        'user_name': '',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.title, '');
      expect(notification.body, '');
      expect(notification.userName, '');
    });

    test('should handle Arabic text correctly', () {
      // Arrange
      final json = {
        'id': '8',
        'user_id': 'admin',
        'title': 'إشعار تجريبي',
        'body': 'هذا إشعار تجريبي باللغة العربية',
        'notification_type': 'news',
        'is_read': false,
        'is_sent': true,
        'priority': 'high',
        'created_at': '2024-01-01T00:00:00Z',
        'user_name': 'أحمد محمد علي',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.title, 'إشعار تجريبي');
      expect(notification.body, 'هذا إشعار تجريبي باللغة العربية');
      expect(notification.userName, 'أحمد محمد علي');
    });
  });

  group('AdminNotificationModel Validation', () {
    test('should handle missing optional boolean fields with defaults', () {
      // Arrange - JSON without is_read and is_sent
      final json = {
        'id': '9',
        'user_id': 'admin',
        'title': 'Default Test',
        'body': 'Testing default values',
        'notification_type': 'general',
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
        // Missing is_read and is_sent
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.isRead, false); // Should default to false
      expect(notification.isSent, false); // Should default to false
    });

    test('should accept valid priority values', () {
      final validPriorities = [
        {'string': 'low', 'enum': NotificationPriority.low},
        {'string': 'normal', 'enum': NotificationPriority.normal},
        {'string': 'high', 'enum': NotificationPriority.high},
        {'string': 'urgent', 'enum': NotificationPriority.urgent},
      ];

      for (final priority in validPriorities) {
        final json = {
          'id': 'priority_test',
          'user_id': 'admin',
          'title': 'Priority Test',
          'body': 'Testing priority',
          'notification_type': 'general',
          'is_read': false,
          'is_sent': true,
          'priority': priority['string'],
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Should not throw
        expect(
          () => AdminNotificationModel.fromJson(json),
          returnsNormally,
          reason: 'Should accept valid priority: ${priority['string']}',
        );

        final notification = AdminNotificationModel.fromJson(json);
        expect(notification.priority, priority['enum']);
      }
    });

    test('should handle admin_notifications table format', () {
      // Test alternate field names from admin_notifications table
      final json = {
        'id': '10',
        'created_by': 'admin_user', // Instead of user_id
        'title': 'Admin Table Test',
        'body': 'Testing admin table format',
        'type': 'general', // Instead of notification_type
        'status': 'sent', // Instead of is_sent
        'priority': 'normal',
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.userId, 'admin_user');
      expect(notification.notificationType, NotificationType.general);
      expect(notification.isSent, true); // Mapped from status == 'sent'
    });

    test('should handle bilingual content', () {
      // Test Arabic and English content
      final json = {
        'id': '11',
        'user_id': 'bilingual_user',
        'title': 'Emergency Alert',
        'title_ar': 'تنبيه طوارئ',
        'body': 'This is an emergency notification',
        'body_ar': 'هذا إشعار طوارئ',
        'notification_type': 'news',
        'is_read': false,
        'is_sent': true,
        'priority': 'urgent',
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final notification = AdminNotificationModel.fromJson(json);

      // Assert
      expect(notification.title, 'Emergency Alert');
      expect(notification.titleAr, 'تنبيه طوارئ');
      expect(notification.body, 'This is an emergency notification');
      expect(notification.bodyAr, 'هذا إشعار طوارئ');
      expect(notification.notificationType, NotificationType.news);
      expect(notification.priority, NotificationPriority.urgent);
    });
  });
}
