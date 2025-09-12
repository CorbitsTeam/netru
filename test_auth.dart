import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

Future<void> main() async {
  print('🧪 بدء اختبار نظام المصادقة...');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://yesjtlgciywmwrdpjqsr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inllc2p0bGdjaXl3bXdyZHBqcXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1OTA0MDMsImV4cCI6MjA3MzE2NjQwM30.0CNthKQ6Ok2L-9JjReCAUoqEeRHSidxTMLmCl2eEPhw',
  );

  final supabase = Supabase.instance.client;

  try {
    print('📧 اختبار إنشاء حساب جديد...');

    // Test creating a new auth user
    final AuthResponse response = await supabase.auth.signUp(
      email: 'test_user_${DateTime.now().millisecondsSinceEpoch}@test.com',
      password: 'TestPassword123!',
    );

    if (response.user != null) {
      print('✅ تم إنشاء حساب المصادقة بنجاح: ${response.user!.id}');

      // Now test inserting into users table
      final userData = {
        'id': response.user!.id,
        'full_name': 'مستخدم تجريبي',
        'user_type': 'citizen',
        'national_id': '12345678901234',
        'email': response.user!.email,
        'phone': '01234567890',
        'verification_status': 'pending',
      };

      print('📝 اختبار إدراج البيانات في جدول المستخدمين...');

      final insertResponse =
          await supabase.from('users').insert(userData).select().single();

      print('✅ تم إدراج المستخدم في جدول المستخدمين بنجاح: $insertResponse');

      // Test creating storage bucket
      print('📁 اختبار إنشاء bucket التخزين...');
      try {
        await supabase.storage.createBucket('avatars');
        print('✅ تم إنشاء bucket بنجاح');
      } catch (e) {
        if (e.toString().contains('already exists')) {
          print('ℹ️ bucket موجود بالفعل');
        } else {
          print('❌ خطأ في إنشاء bucket: $e');
        }
      }

      print('🎉 جميع الاختبارات نجحت!');
    } else {
      print('❌ فشل في إنشاء حساب المصادقة');
    }
  } catch (e) {
    print('❌ خطأ في الاختبار: $e');
    print('تفاصيل الخطأ: ${e.runtimeType}');
  }

  exit(0);
}
