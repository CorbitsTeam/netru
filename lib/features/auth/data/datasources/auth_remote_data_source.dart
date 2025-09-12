import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/identity_document_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> loginWithEmailAndPassword(String email, String password);
  Future<UserModel> createUser(UserModel user, String password);

  // New methods for two-phase signup with email verification
  Future<String> signUpWithEmailOnly(String email, String password);
  Future<UserModel> completeUserProfile(UserModel user, String authUserId);
  Future<bool> resendVerificationEmail();
  Future<UserModel?> verifyEmailAndCompleteSignup(UserModel userData);

  Future<IdentityDocumentModel> createIdentityDocument(
    IdentityDocumentModel document,
  );
  Future<String> uploadImage(File imageFile, String fileName);
  Future<bool> checkNationalIdExists(String nationalId);
  Future<bool> checkPassportExists(String passportNumber);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<UserModel?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // try {
    //   await _supabaseClient.auth.signOut();
    //   print('✅ تم تسجيل الخروج من الجلسة القديمة');
    // } catch (e) {
    //   print('⚠️ فشل تسجيل الخروج: $e');
    // }
    try {
      print('🔐 محاولة تسجيل الدخول بالبريد الإلكتروني: $email');

      final AuthResponse authResponse = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (authResponse.user == null || authResponse.session == null) {
        throw Exception('فشل في تسجيل الدخول - تحقق من البيانات المدخلة');
      }

      // جلب بيانات المستخدم الكاملة من جدول users
      final response =
          await _supabaseClient
              .from('users')
              .select()
              .eq('email', email)
              .maybeSingle();

      if (response == null) {
        throw Exception('بيانات المستخدم غير موجودة');
      }

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');

      try {
        await _supabaseClient.auth.signOut();
      } catch (_) {}

      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<UserModel> createUser(UserModel user, String password) async {
    try {
      print('🔄 بدء إنشاء المستخدم: ${user.fullName}');

      // Check if user is already authenticated (for profile completion flow)
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.emailConfirmedAt != null) {
        print('✅ مستخدم مصدق موجود بالفعل: ${currentUser.id}');
        print('📧 إيميل المستخدم: ${currentUser.email}');

        // Use the authenticated user's data for profile completion
        return await _completeExistingUserProfile(user, currentUser);
      }

      // Continue with normal user creation flow if no authenticated user
      print('🆕 لا يوجد مستخدم مصدق، إنشاء حساب جديد...');

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

      // 1️⃣ إنشاء حساب المصادقة
      print('🔐 إنشاء حساب المصادقة...');
      final AuthResponse authResponse = await _supabaseClient.auth.signUp(
        email: emailToUse,
        password: password,
      );

      if (authResponse.user == null) {
        print('❌ فشل في إنشاء حساب المصادقة');
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      print('✅ تم إنشاء حساب المصادقة بنجاح: ${authResponse.user!.id}');
      final authUserId = authResponse.user!.id;

      // 2️⃣ تسجيل الدخول فوراً للحصول على Session
      final signInResponse = await _supabaseClient.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );

      if (signInResponse.session == null) {
        throw Exception('فشل تسجيل الدخول بعد إنشاء الحساب');
      }

      print(
        '🔑 جلسة صالحة: ${signInResponse.session!.accessToken.substring(0, 15)}...',
      );

      // 3️⃣ تجهيز بيانات المستخدم للجدول
      final userData = user.toCreateJson();
      userData['id'] = authUserId;
      userData['email'] = emailToUse;
      userData['verification_status'] = 'pending';

      print('📝 بيانات المستخدم للقاعدة: $userData');

      // 4️⃣ إدخال البيانات في جدول users
      print('💾 حفظ بيانات المستخدم في قاعدة البيانات...');
      final response =
          await _supabaseClient
              .from('users')
              .insert(userData)
              .select()
              .single();

      print('✅ تم حفظ المستخدم في قاعدة البيانات بنجاح');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');

      // تنظيف الحساب إذا فشل التسجيل
      try {
        print('🔄 محاولة تنظيف حساب المصادقة...');
        await _supabaseClient.auth.signOut();
      } catch (cleanupError) {
        print('⚠️ خطأ في تنظيف حساب المصادقة: $cleanupError');
      }

      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  // 🆕 New method for initial signup with email verification
  @override
  Future<String> signUpWithEmailOnly(String email, String password) async {
    try {
      print('📧 بدء إنشاء حساب مصادقة فقط للإيميل: $email');

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('عنوان البريد الإلكتروني غير صحيح');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      // Create auth account only - no database entry yet
      final AuthResponse authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      print('✅ تم إنشاء حساب المصادقة: ${authResponse.user!.id}');
      print('📩 تم إرسال رسالة تأكيد للبريد الإلكتروني');

      return authResponse.user!.id;
    } catch (e) {
      print('❌ خطأ في إنشاء حساب المصادقة: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  // 🆕 Complete user profile after email verification
  @override
  Future<UserModel> completeUserProfile(
    UserModel user,
    String authUserId,
  ) async {
    try {
      print('📝 إكمال ملف المستخدم للـ ID: $authUserId');

      // Prepare user data for database
      final userData = user.toCreateJson();
      userData['id'] = authUserId;
      userData['verification_status'] = 'verified'; // Email is verified now

      print('💾 حفظ بيانات المستخدم في قاعدة البيانات...');

      final response =
          await _supabaseClient
              .from('users')
              .insert(userData)
              .select()
              .single();

      print('✅ تم حفظ ملف المستخدم بنجاح');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إكمال ملف المستخدم: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  // 🆕 Resend verification email
  @override
  Future<bool> resendVerificationEmail() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      await _supabaseClient.auth.resend(
        type: OtpType.signup,
        email: user.email!,
      );

      print('📩 تم إعادة إرسال رسالة التأكيد');
      return true;
    } catch (e) {
      print('❌ خطأ في إعادة إرسال رسالة التأكيد: $e');
      return false;
    }
  }

  // 🆕 Verify email and complete signup
  @override
  Future<UserModel?> verifyEmailAndCompleteSignup(UserModel userData) async {
    try {
      print('🔍 التحقق من حالة تأكيد الإيميل...');

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        print('❌ لا يوجد مستخدم مسجل دخول');
        return null;
      }

      // Check if email is confirmed
      if (user.emailConfirmedAt == null) {
        print('⏳ البريد الإلكتروني لم يتم تأكيده بعد');
        return null;
      }

      // Check if user profile already exists
      final existingUser =
          await _supabaseClient
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (existingUser != null) {
        print('✅ ملف المستخدم موجود بالفعل');
        return UserModel.fromJson(existingUser);
      }

      // Complete user profile
      print('📝 إكمال ملف المستخدم...');
      return await completeUserProfile(userData, user.id);
    } catch (e) {
      print('❌ خطأ في التحقق وإكمال التسجيل: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  String _parseErrorMessage(String error) {
    print('🔍 تحليل رسالة الخطأ: $error');

    // Check for authentication errors first
    if (error.contains('Invalid login credentials') ||
        error.contains('Email not confirmed') ||
        error.contains('Invalid email or password')) {
      return 'بيانات الدخول غير صحيحة';
    }

    if (error.contains('Email not found') ||
        error.contains('User not found') ||
        error.contains('المستخدم غير موجود')) {
      return 'المستخدم غير موجود';
    }

    if (error.contains('فشل في تسجيل الدخول - تحقق من كلمة المرور')) {
      return 'كلمة المرور غير صحيحة';
    }

    // Check for RLS policy errors
    if (error.contains('row-level security policy') ||
        error.contains('Unauthorized') ||
        error.contains('42501')) {
      return 'خطأ في صلاحيات قاعدة البيانات - يرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني';
    }

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
      final path = 'user_docs/$uniqueFileName';

      print('📁 مسار الملف: $path');

      // Upload file using the correct Supabase format
      final String fullPath = await _supabaseClient.storage
          .from('documents') // Use documents bucket for identity documents
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      print('✅ تم رفع الملف بنجاح: $fullPath');

      // Get the public URL
      final publicUrl = _supabaseClient.storage
          .from('documents')
          .getPublicUrl(path);

      print('🔗 الرابط العام: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');

      // Check if it's a bucket creation issue
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('bucket does not exist')) {
        print('🔄 محاولة إنشاء bucket...');
        try {
          await _supabaseClient.storage.createBucket(
            'documents',
            const BucketOptions(public: true),
          );
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

  // Helper method for completing existing authenticated user profile
  Future<UserModel> _completeExistingUserProfile(
    UserModel user,
    User currentUser,
  ) async {
    try {
      print('📝 إكمال ملف المستخدم المصدق: ${currentUser.id}');

      // Check if user profile already exists in database
      final existingUser =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('id', currentUser.id)
              .maybeSingle();

      if (existingUser != null) {
        print('✅ ملف المستخدم موجود بالفعل');
        return UserModel.fromJson(existingUser);
      }

      // Create new user profile with authenticated user's ID
      print('🆕 إنشاء ملف مستخدم جديد للمستخدم المصدق');

      final userData = user.toCreateJson();
      userData['id'] = currentUser.id;
      userData['email'] = currentUser.email ?? user.email;
      userData['verification_status'] = 'verified'; // Email is already verified

      print('💾 حفظ بيانات المستخدم في قاعدة البيانات...');

      final response =
          await _supabaseClient
              .from('users')
              .insert(userData)
              .select()
              .single();

      print('✅ تم حفظ ملف المستخدم بنجاح');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إكمال ملف المستخدم: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      throw Exception('خطأ في تسجيل الخروج');
    }
  }
}
