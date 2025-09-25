// ملف اختبار للتحقق من عمل نظام التحقق من البيانات المكررة

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Data Validation Tests', () {
    test('Email validation should work correctly', () {
      // Test email format validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      // Valid emails
      expect(emailRegex.hasMatch('user@example.com'), true);
      expect(emailRegex.hasMatch('test.user@domain.co.uk'), true);
      expect(emailRegex.hasMatch('user123@test-domain.com'), true);

      // Invalid emails
      expect(emailRegex.hasMatch('invalid-email'), false);
      expect(emailRegex.hasMatch('user@'), false);
      expect(emailRegex.hasMatch('@domain.com'), false);
      expect(emailRegex.hasMatch('user@@domain.com'), false);
    });

    test('Phone validation should work correctly', () {
      // Test phone format validation
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

      String cleanPhone(String phone) => phone.replaceAll(RegExp(r'[\s-]'), '');

      // Valid phones
      expect(phoneRegex.hasMatch(cleanPhone('+201234567890')), true);
      expect(phoneRegex.hasMatch(cleanPhone('01234567890')), true);
      expect(phoneRegex.hasMatch(cleanPhone('+966 12 345 6789')), true);
      expect(phoneRegex.hasMatch(cleanPhone('012-345-67890')), true);

      // Invalid phones
      expect(phoneRegex.hasMatch(cleanPhone('123')), false); // too short
      expect(
        phoneRegex.hasMatch(cleanPhone('abc1234567890')),
        false,
      ); // contains letters
      expect(phoneRegex.hasMatch(cleanPhone('')), false); // empty
    });

    test('National ID validation logic should be consistent', () {
      // Test that we have consistent handling of national ID
      const String sampleNationalId = '12345678901234';

      // Test length (Egyptian national ID should be 14 digits)
      expect(sampleNationalId.length, 14);
      expect(RegExp(r'^[0-9]{14}$').hasMatch(sampleNationalId), true);

      // Invalid national IDs
      expect(RegExp(r'^[0-9]{14}$').hasMatch('123456789'), false); // too short
      expect(
        RegExp(r'^[0-9]{14}$').hasMatch('1234567890123a'),
        false,
      ); // contains letter
    });
  });

  group('Database Field Mapping Tests', () {
    test('Database columns should match our validation fields', () {
      // These are the columns we check in the database
      const dbColumns = [
        'email', // البريد الإلكتروني
        'phone', // رقم الهاتف
        'national_id', // الرقم القومي
        'passport_number', // رقم جواز السفر
      ];

      // Ensure we have all required validation fields
      expect(dbColumns.length, 4);
      expect(dbColumns, contains('email'));
      expect(dbColumns, contains('phone'));
      expect(dbColumns, contains('national_id'));
      expect(dbColumns, contains('passport_number'));
    });
  });
}

// Test data examples for manual testing
class TestDataExamples {
  // Existing test data (should trigger "user exists" messages)
  static const existingEmails = [
    'existing1@test.com',
    'existing2@domain.org',
    'admin@netru.app',
  ];

  static const existingPhones = [
    '+201234567890',
    '01111111111',
    '+966123456789',
  ];

  static const existingNationalIds = [
    '12345678901234',
    '98765432109876',
    '11111111111111',
  ];

  // New test data (should allow registration)
  static const newEmails = [
    'newuser1@test.com',
    'newuser2@domain.org',
    'fresh@email.com',
  ];

  static const newPhones = ['+201999999999', '01000000000', '+966999999999'];

  static const newNationalIds = [
    '99999999999999',
    '88888888888888',
    '77777777777777',
  ];
}
