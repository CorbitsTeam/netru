import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/identity_document_model.dart';
import '../../domain/entities/user_entity.dart';

/// Unified Auth Data Source
/// يجمع كل العمليات المتعلقة بالمصادقة وإدارة المستخدمين
abstract class AuthDataSource {
  // ========================
  // Authentication Methods
  // ========================
  Future<UserModel?> loginWithEmail(String email, String password);
  Future<UserModel?> loginWithCredentials({
    required String identifier,
    required String password,
    required UserType userType,
  });
  Future<void> logout();

  // ========================
  // Registration Methods
  // ========================
  Future<UserModel> createUser(UserModel user, String password);
  Future<String> signUpWithEmailOnly(String email, String password);
  Future<UserModel> completeUserProfile(UserModel user, String authUserId);

  // ========================
  // Email Verification
  // ========================
  Future<bool> resendVerificationEmail();
  Future<UserModel?> verifyEmailAndCompleteSignup(UserModel userData);

  // ========================
  // User Retrieval Methods
  // ========================
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserById(String userId);
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel?> getUserByNationalId(String nationalId);
  Future<UserModel?> getUserByPassport(String passportNumber);

  // ========================
  // User Update Methods
  // ========================
  Future<UserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  );

  // ========================
  // Validation Methods - Critical Data Check
  // ========================
  /// التحقق من وجود الإيميل في جدول المستخدمين
  Future<bool> checkEmailExistsInUsers(String email);

  /// التحقق من وجود الإيميل في نظام المصادقة
  Future<bool> checkEmailExistsInAuth(String email);

  /// التحقق من وجود رقم التليفون
  Future<bool> checkPhoneExists(String phone);

  /// التحقق من وجود الرقم القومي
  Future<bool> checkNationalIdExists(String nationalId);

  /// التحقق من وجود رقم الباسبور
  Future<bool> checkPassportExists(String passportNumber);

  /// التحقق العام من وجود المستخدم (متعدد الطرق)
  Future<bool> checkUserExists(String identifier);

  // ========================
  // Document Management
  // ========================
  Future<IdentityDocumentModel> createIdentityDocument(
    IdentityDocumentModel document,
  );
  Future<String> uploadImage(File imageFile, String fileName);
}

/// Supabase Implementation of Auth Data Source
class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSource({required this.supabaseClient});

  // ========================
  // Authentication Methods
  // ========================

  @override
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      print('🔐 محاولة تسجيل الدخول بالإيميل: $email');

      final AuthResponse authResponse = await supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (authResponse.user == null || authResponse.session == null) {
        throw Exception('فشل في تسجيل الدخول - تحقق من البريد أو كلمة المرور');
      }

      print('✅ تم تسجيل الدخول بنجاح للمستخدم: ${authResponse.user!.id}');

      // جلب بيانات المستخدم من جدول users
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('id', authResponse.user!.id)
              .maybeSingle();

      if (response == null) {
        throw Exception('ملف المستخدم غير موجود - يرجى استكمال ملفك');
      }

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<UserModel?> loginWithCredentials({
    required String identifier,
    required String password,
    required UserType userType,
  }) async {
    try {
      print('🔐 تسجيل الدخول بـ ${userType.name}: $identifier');

      // استخدام دالة RPC مخصصة للتسجيل حسب نوع المستخدم
      final response = await supabaseClient.rpc(
        'custom_login',
        params: {
          'p_identifier': identifier,
          'p_password': password,
          'p_user_type': userType.name,
        },
      );

      if (response == null || (response is List && response.isEmpty)) {
        switch (userType) {
          case UserType.citizen:
            throw Exception('الرقم القومي أو كلمة المرور غير صحيحة');
          case UserType.foreigner:
            throw Exception('رقم جواز السفر أو كلمة المرور غير صحيحة');
          case UserType.admin:
            throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
      }

      Map<String, dynamic> userData;
      if (response is List && response.isNotEmpty) {
        userData = response.first as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        userData = response;
      } else {
        throw Exception('تنسيق غير متوقع من دالة تسجيل الدخول');
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      throw Exception('خطأ في تسجيل الخروج');
    }
  }

  // ========================
  // Registration Methods
  // ========================

  @override
  Future<UserModel> createUser(UserModel user, String password) async {
    try {
      print('🔄 بدء إنشاء المستخدم: ${user.fullName}');

      // التحقق من المستخدم المصدق الحالي أولاً
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.emailConfirmedAt != null) {
        print('✅ مستخدم مصدق موجود بالفعل: ${currentUser.id}');
        return await _completeExistingUserProfile(user, currentUser);
      }

      // التحقق من البيانات المطلوبة
      await _validateUserData(user, password);

      // إنشاء الإيميل المناسب
      String emailToUse = _generateEmailForUser(user);
      print('📧 البريد المستخدم: $emailToUse');

      // إنشاء حساب المصادقة
      final AuthResponse authResponse = await supabaseClient.auth.signUp(
        email: emailToUse,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      print('✅ تم إنشاء حساب المصادقة: ${authResponse.user!.id}');

      // تسجيل الدخول فوراً
      final signInResponse = await supabaseClient.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );

      if (signInResponse.session == null) {
        throw Exception('فشل تسجيل الدخول بعد إنشاء الحساب');
      }

      // حفظ بيانات المستخدم في قاعدة البيانات
      return await _saveUserToDatabase(user, authResponse.user!.id, emailToUse);
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');
      await _cleanupFailedRegistration();
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<String> signUpWithEmailOnly(String email, String password) async {
    try {
      print('📧 بدء إنشاء حساب مصادقة للإيميل: $email');

      // التحقق من صحة الإيميل
      if (!_isValidEmail(email)) {
        throw Exception('عنوان البريد الإلكتروني غير صحيح');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      // التحقق من وجود الإيميل مسبقاً
      final emailExists = await checkEmailExistsInUsers(email);
      if (emailExists) {
        throw Exception('البريد الإلكتروني مستخدم من قبل');
      }

      final AuthResponse authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      print('✅ تم إنشاء حساب المصادقة: ${authResponse.user!.id}');
      return authResponse.user!.id;
    } catch (e) {
      print('❌ خطأ في إنشاء حساب المصادقة: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  @override
  Future<UserModel> completeUserProfile(
    UserModel user,
    String authUserId,
  ) async {
    try {
      print('📝 إكمال ملف المستخدم: $authUserId');

      // التحقق من عدم تكرار البيانات الحساسة
      await _validateUniqueUserData(user);

      final userData = user.toCreateJson();
      userData['id'] = authUserId;
      userData['verification_status'] = 'verified';

      final response =
          await supabaseClient.from('users').insert(userData).select().single();

      print('✅ تم حفظ ملف المستخدم بنجاح');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في إكمال ملف المستخدم: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  // ========================
  // Email Verification
  // ========================

  @override
  Future<bool> resendVerificationEmail() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      await supabaseClient.auth.resend(
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

  @override
  Future<UserModel?> verifyEmailAndCompleteSignup(UserModel userData) async {
    try {
      print('🔍 التحقق من حالة تأكيد الإيميل...');

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        print('❌ لا يوجد مستخدم مسجل دخول');
        return null;
      }

      if (user.emailConfirmedAt == null) {
        print('⏳ البريد الإلكتروني لم يتم تأكيده بعد');
        return null;
      }

      // التحقق من وجود ملف المستخدم
      final existingUser =
          await supabaseClient
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (existingUser != null) {
        print('✅ ملف المستخدم موجود بالفعل');
        return UserModel.fromJson(existingUser);
      }

      // إكمال ملف المستخدم
      return await completeUserProfile(userData, user.id);
    } catch (e) {
      print('❌ خطأ في التحقق وإكمال التسجيل: $e');
      throw Exception(_parseErrorMessage(e.toString()));
    }
  }

  // ========================
  // User Retrieval Methods
  // ========================

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) return null;

      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('id', session.user.id)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم الحالي: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('id', userId)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم بالـ ID: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('email', email)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم بالإيميل: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByNationalId(String nationalId) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('national_id', nationalId)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم بالرقم القومي: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByPassport(String passportNumber) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('passport_number', passportNumber)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ خطأ في جلب المستخدم برقم جواز السفر: $e');
      return null;
    }
  }

  // ========================
  // User Update Methods
  // ========================

  @override
  Future<UserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      // الحقول المسموح تحديثها
      final allowedFields = {
        'full_name',
        'phone',
        'location',
        'address',
        'profile_image',
      };

      final updateData = <String, dynamic>{};
      for (final key in userData.keys) {
        if (allowedFields.contains(key)) {
          updateData[key] = userData[key];
        }
      }

      if (updateData.isEmpty) {
        throw Exception('لا توجد بيانات صالحة للتحديث');
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await supabaseClient
              .from('users')
              .update(updateData)
              .eq('id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات المستخدم: $e');
    }
  }

  // ========================
  // Critical Validation Methods
  // ========================

  @override
  Future<bool> checkEmailExistsInUsers(String email) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('id')
              .eq('email', email)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ خطأ في التحقق من الإيميل في جدول المستخدمين: $e');
      return false;
    }
  }

  @override
  Future<bool> checkEmailExistsInAuth(String email) async {
    try {
      // التحقق من نظام المصادقة عبر محاولة إنشاء حساب
      // هذا سيفشل إذا كان الإيميل موجود مسبقاً
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: 'temp_password_for_check',
      );

      // إذا نجح في الإنشاء، يعني الإيميل غير موجود
      if (response.user != null) {
        // حذف الحساب المؤقت
        try {
          await supabaseClient.auth.admin.deleteUser(response.user!.id);
        } catch (deleteError) {
          print('⚠️ خطأ في حذف الحساب المؤقت: $deleteError');
        }
        return false;
      }

      return true;
    } catch (e) {
      // إذا فشل في الإنشاء بسبب وجود الإيميل، يعني الإيميل موجود
      if (e.toString().contains('already registered') ||
          e.toString().contains('User already registered')) {
        return true;
      }

      print('❌ خطأ في التحقق من الإيميل في نظام المصادقة: $e');
      return false;
    }
  }

  @override
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('id')
              .eq('phone', phone)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ خطأ في التحقق من رقم التليفون: $e');
      return false;
    }
  }

  @override
  Future<bool> checkNationalIdExists(String nationalId) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('id')
              .eq('national_id', nationalId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ خطأ في التحقق من الرقم القومي: $e');
      return false;
    }
  }

  @override
  Future<bool> checkPassportExists(String passportNumber) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('id')
              .eq('passport_number', passportNumber)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ خطأ في التحقق من رقم جواز السفر: $e');
      return false;
    }
  }

  @override
  Future<bool> checkUserExists(String identifier) async {
    try {
      // التحقق من الإيميل أولاً
      if (_isValidEmail(identifier)) {
        return await checkEmailExistsInUsers(identifier);
      }

      // التحقق من الرقم القومي (14 رقم)
      if (identifier.length == 14 && RegExp(r'^\d{14}$').hasMatch(identifier)) {
        return await checkNationalIdExists(identifier);
      }

      // التحقق من رقم جواز السفر
      if (identifier.length >= 6 && identifier.length <= 12) {
        return await checkPassportExists(identifier);
      }

      // التحقق من رقم التليفون
      if (RegExp(r'^\+?[0-9]{10,15}$').hasMatch(identifier)) {
        return await checkPhoneExists(identifier);
      }

      return false;
    } catch (e) {
      print('❌ خطأ في التحقق من وجود المستخدم: $e');
      return false;
    }
  }

  // ========================
  // Document Management
  // ========================

  @override
  Future<IdentityDocumentModel> createIdentityDocument(
    IdentityDocumentModel document,
  ) async {
    try {
      final response =
          await supabaseClient
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

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_${fileName.replaceAll(' ', '_')}';
      final path = 'user_docs/$uniqueFileName';

      await supabaseClient.storage
          .from('documents')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabaseClient.storage
          .from('documents')
          .getPublicUrl(path);

      print('✅ تم رفع الملف بنجاح: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');

      if (e.toString().contains('Bucket not found')) {
        try {
          await supabaseClient.storage.createBucket(
            'documents',
            const BucketOptions(public: true),
          );
          return await uploadImage(imageFile, fileName);
        } catch (bucketError) {
          print('❌ فشل في إنشاء bucket: $bucketError');
        }
      }

      throw Exception('خطأ في رفع الصورة: ${e.toString()}');
    }
  }

  // ========================
  // Private Helper Methods
  // ========================

  Future<void> _validateUserData(UserModel user, String password) async {
    if (user.fullName.trim().isEmpty) {
      throw Exception('الاسم الكامل مطلوب');
    }

    if (password.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    // التحقق من البيانات الحساسة
    await _validateUniqueUserData(user);
  }

  Future<void> _validateUniqueUserData(UserModel user) async {
    // التحقق من الإيميل
    if (user.email != null && user.email!.isNotEmpty) {
      final emailExists = await checkEmailExistsInUsers(user.email!);
      if (emailExists) {
        throw Exception('البريد الإلكتروني مستخدم من قبل');
      }
    }

    // التحقق من رقم التليفون
    if (user.phone != null && user.phone!.isNotEmpty) {
      final phoneExists = await checkPhoneExists(user.phone!);
      if (phoneExists) {
        throw Exception('رقم التليفون مستخدم من قبل');
      }
    }

    // التحقق من الرقم القومي
    if (user.nationalId != null && user.nationalId!.isNotEmpty) {
      final nationalIdExists = await checkNationalIdExists(user.nationalId!);
      if (nationalIdExists) {
        throw Exception('الرقم القومي مستخدم من قبل');
      }
    }

    // التحقق من رقم جواز السفر
    if (user.passportNumber != null && user.passportNumber!.isNotEmpty) {
      final passportExists = await checkPassportExists(user.passportNumber!);
      if (passportExists) {
        throw Exception('رقم جواز السفر مستخدم من قبل');
      }
    }
  }

  String _generateEmailForUser(UserModel user) {
    if (user.email != null && user.email!.isNotEmpty) {
      if (!_isValidEmail(user.email!)) {
        throw Exception('عنوان البريد الإلكتروني غير صحيح');
      }
      return user.email!;
    }

    if (user.nationalId != null && user.nationalId!.isNotEmpty) {
      return '${user.nationalId}@netru.app';
    }

    if (user.passportNumber != null && user.passportNumber!.isNotEmpty) {
      return '${user.passportNumber}@netru.app';
    }

    throw Exception('يجب إدخال البريد الإلكتروني أو الرقم القومي/جواز السفر');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<UserModel> _saveUserToDatabase(
    UserModel user,
    String authUserId,
    String email,
  ) async {
    final userData = user.toCreateJson();
    userData['id'] = authUserId;
    userData['email'] = email;
    userData['verification_status'] = 'pending';

    final response =
        await supabaseClient.from('users').insert(userData).select().single();

    print('✅ تم حفظ المستخدم في قاعدة البيانات');
    return UserModel.fromJson(response);
  }

  Future<UserModel> _completeExistingUserProfile(
    UserModel user,
    User currentUser,
  ) async {
    final existingUser =
        await supabaseClient
            .from('users')
            .select('*')
            .eq('id', currentUser.id)
            .maybeSingle();

    if (existingUser != null) {
      return UserModel.fromJson(existingUser);
    }

    final userData = user.toCreateJson();
    userData['id'] = currentUser.id;
    userData['email'] = currentUser.email ?? user.email;
    userData['verification_status'] = 'verified';

    final response =
        await supabaseClient.from('users').insert(userData).select().single();

    return UserModel.fromJson(response);
  }

  Future<void> _cleanupFailedRegistration() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      print('⚠️ خطأ في تنظيف حساب المصادقة: $e');
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('البريد الإلكتروني مستخدم من قبل') ||
        error.contains('رقم التليفون مستخدم من قبل') ||
        error.contains('الرقم القومي مستخدم من قبل') ||
        error.contains('رقم جواز السفر مستخدم من قبل')) {
      return error;
    }

    if (error.contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }

    if (error.contains('Email not found') || error.contains('User not found')) {
      return 'المستخدم غير موجود';
    }

    if (error.contains('duplicate key value violates unique constraint')) {
      if (error.contains('email')) return 'البريد الإلكتروني مستخدم من قبل';
      if (error.contains('national_id')) return 'الرقم القومي مستخدم من قبل';
      if (error.contains('passport_number'))
        return 'رقم جواز السفر مستخدم من قبل';
      if (error.contains('phone')) return 'رقم التليفون مستخدم من قبل';
      return 'هذه البيانات مستخدمة من قبل';
    }

    if (error.contains('Invalid email')) {
      return 'عنوان البريد الإلكتروني غير صحيح';
    }

    if (error.contains('Password should be at least')) {
      return 'كلمة المرور ضعيفة جداً - يجب أن تكون 6 أحرف على الأقل';
    }

    return 'خطأ في العملية: ${error.split(':').last.trim()}';
  }
}
