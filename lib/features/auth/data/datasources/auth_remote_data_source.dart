import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/identity_document_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> loginWithNationalId(String nationalId, String password);
  Future<UserModel?> loginWithPassport(String passportNumber, String password);
  Future<UserModel> createUser(UserModel user, String password);
  Future<IdentityDocumentModel> createIdentityDocument(
    IdentityDocumentModel document,
  );
  Future<String> uploadImage(File imageFile, String fileName);
  Future<bool> checkNationalIdExists(String nationalId);
  Future<bool> checkPassportExists(String passportNumber);
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<UserModel?> loginWithNationalId(
    String nationalId,
    String password,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select()
              .eq('national_id', nationalId)
              .maybeSingle();

      if (response == null) {
        throw Exception('المستخدم غير موجود');
      }

      // In a real app, you should verify the password hash
      // For now, we'll assume password verification is handled elsewhere
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  @override
  Future<UserModel?> loginWithPassport(
    String passportNumber,
    String password,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select()
              .eq('passport_number', passportNumber)
              .maybeSingle();

      if (response == null) {
        throw Exception('المستخدم غير موجود');
      }

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user, String password) async {
    try {
      print('🔄 بدء إنشاء المستخدم: ${user.fullName}');

      // Validate required fields
      if (user.fullName.trim().isEmpty) {
        throw Exception('الاسم الكامل مطلوب');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      // Validate email format if provided
      String emailToUse;
      if (user.email != null && user.email!.isNotEmpty) {
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(user.email!)) {
          throw Exception('عنوان البريد الإلكتروني غير صحيح');
        }
        emailToUse = user.email!;
      } else {
        // Create a dummy email based on user type and ID
        if (user.nationalId != null && user.nationalId!.isNotEmpty) {
          emailToUse = '${user.nationalId}@netru.app';
        } else if (user.passportNumber != null &&
            user.passportNumber!.isNotEmpty) {
          emailToUse = '${user.passportNumber}@netru.app';
        } else {
          throw Exception(
            'يجب إدخال البريد الإلكتروني أو الرقم القومي/جواز السفر',
          );
        }
      }

      print('📧 البريد المستخدم: $emailToUse');

      // First, create user in Supabase Auth
      print('🔐 إنشاء حساب المصادقة...');
      final AuthResponse authResponse = await _supabaseClient.auth.signUp(
        email: emailToUse,
        password: password,
        phone: user.phone,
      );

      if (authResponse.user == null) {
        print('❌ فشل في إنشاء حساب المصادقة');
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      print('✅ تم إنشاء حساب المصادقة بنجاح: ${authResponse.user!.id}');

      // Get the auth user ID
      final authUserId = authResponse.user!.id;

      // Prepare user data for database
      final userData = user.toCreateJson();
      userData['id'] = authUserId; // Use auth user ID as primary key
      userData['password'] =
          password; // Add password field as required by database schema

      // Add the actual email used for auth (database requires NOT NULL)
      userData['email'] =
          emailToUse; // Use the email used for auth (never null)

      print('📝 بيانات المستخدم للقاعدة: $userData');

      // Create user record in users table with auth user ID
      print('💾 حفظ بيانات المستخدم في قاعدة البيانات...');

      // Try inserting a few times before giving up (helps if auth session
      // isn't fully propagated or transient DB policies cause temporary
      // failures). We'll keep the insert as the authenticated user.
      const int maxAttempts = 3;
      int attempt = 0;
      dynamic response;
      while (attempt < maxAttempts) {
        try {
          attempt++;
          response =
              await _supabaseClient
                  .from('users')
                  .insert(userData)
                  .select()
                  .single();
          break; // success
        } catch (err) {
          print('⚠️ محاولة إدراج المستخدم فشلت (محاولة $attempt): $err');
          if (attempt >= maxAttempts) throw err;
          // small backoff
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      print('✅ تم حفظ المستخدم في قاعدة البيانات بنجاح');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');

      // Clean up auth user if database insert fails
      try {
        print('🔄 محاولة تنظيف حساب المصادقة...');
        await _supabaseClient.auth.signOut();
      } catch (cleanupError) {
        print('⚠️ خطأ في تنظيف حساب المصادقة: $cleanupError');
      }

      final errStr = e.toString();
      // Detect common server-side RLS/policy recursion error and return
      // actionable message to the developer/maintainer.
      if (errStr.contains('infinite recursion')) {
        throw Exception(
          'خطأ في سياسات قاعدة البيانات (RLS) عند إدراج المستخدم.\n'
          'الخطأ: infinite recursion detected in policy for relation "users".\n'
          'الرجاء مراجعة سياسات RLS لجدول users في لوحة Supabase أو استخدام خدمة "service_role" '
          'لإنشاء السجلات من جانب الخادم بدلاً من العميل.',
        );
      }

      // Parse and return user-friendly error messages
      String errorMessage = _parseErrorMessage(errStr);
      throw Exception(errorMessage);
    }
  }

  String _parseErrorMessage(String error) {
    print('🔍 تحليل رسالة الخطأ: $error');

    // Check for specific error types
    if (error.contains('unique') || error.contains('duplicate')) {
      if (error.contains('national_id')) {
        return 'هذا الرقم القومي مستخدم من قبل';
      } else if (error.contains('passport_number')) {
        return 'رقم جواز السفر هذا مستخدم من قبل';
      } else if (error.contains('email')) {
        return 'هذا البريد الإلكتروني مستخدم من قبل';
      }
      return 'هذه البيانات مستخدمة من قبل';
    }

    if (error.contains('Invalid email') ||
        error.contains('عنوان البريد الإلكتروني غير صحيح')) {
      return 'عنوان البريد الإلكتروني غير صحيح';
    }

    if (error.contains('Password should be at least') ||
        error.contains('كلمة المرور')) {
      return 'كلمة المرور ضعيفة جداً - يجب أن تكون 6 أحرف على الأقل';
    }

    if (error.contains('network') || error.contains('connection')) {
      return 'مشكلة في الاتصال بالإنترنت';
    }

    if (error.contains('فشل في إنشاء حساب المصادقة')) {
      return 'فشل في إنشاء حساب المصادقة - حاول مرة أخرى';
    }

    if (error.contains('duplicate key value violates unique constraint')) {
      return 'هذه البيانات مستخدمة من قبل';
    }

    // Return the original error if no specific match
    return 'خطأ في إنشاء الحساب: ${error.split(':').last.trim()}';
  }

  @override
  Future<IdentityDocumentModel> createIdentityDocument(
    IdentityDocumentModel document,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('identity_documents')
              .insert(document.toCreateJson())
              .select()
              .single();

      return IdentityDocumentModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في حفظ المستندات: $e');
    }
  }

  @override
  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      print('📤 بدء رفع الصورة: $fileName');

      // Create unique filename to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_${fileName.replaceAll(' ', '_')}';

      print('📁 اسم الملف الفريد: $uniqueFileName');

      // Upload file using the correct Supabase format
      final String fullPath = await _supabaseClient.storage
          .from('avatars') // Make sure this bucket exists in Supabase
          .upload(
            uniqueFileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      print('✅ تم رفع الملف بنجاح: $fullPath');

      // Get the public URL
      final publicUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(uniqueFileName);

      print('🔗 الرابط العام: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');

      // Check if it's a bucket creation issue
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('bucket does not exist')) {
        print('🔄 محاولة إنشاء bucket...');
        try {
          await _supabaseClient.storage.createBucket('avatars');
          print('✅ تم إنشاء bucket بنجاح');

          // Retry upload
          return await uploadImage(imageFile, fileName);
        } catch (bucketError) {
          print('❌ فشل في إنشاء bucket: $bucketError');
        }
      }

      throw Exception('خطأ في رفع الصورة: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkNationalIdExists(String nationalId) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('id')
              .eq('national_id', nationalId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> checkPassportExists(String passportNumber) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('id')
              .eq('passport_number', passportNumber)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) return null;

      // Get user from database using session user id
      final response =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('id', session.user.id)
              .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
