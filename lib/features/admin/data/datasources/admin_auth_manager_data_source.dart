import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';

abstract class AdminUserRemoteDataSource {
  Future<List<Map<String, dynamic>>> getUsersWithoutAuthAccount();
  Future<bool> createAuthAccountForUser({
    required String email,
    required String defaultPassword,
    required String userId,
  });
  Future<bool> checkUserHasAuthAccount(String email);
  Future<Map<String, dynamic>> getUserByEmail(String email);
}

class AdminUserRemoteDataSourceImpl implements AdminUserRemoteDataSource {
  final SupabaseClient supabaseClient;
  final ApiClient apiClient;

  AdminUserRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.apiClient,
  });

  @override
  Future<List<Map<String, dynamic>>> getUsersWithoutAuthAccount() async {
    try {
      print('🔍 البحث عن المستخدمين بدون حسابات authentication...');

      // جلب جميع المستخدمين من قاعدة البيانات
      final usersResponse = await supabaseClient
          .from('users')
          .select('id, email, full_name, user_type, created_at')
          .not('email', 'is', null);

      final users = usersResponse as List<dynamic>;
      final usersWithoutAuth = <Map<String, dynamic>>[];

      for (final user in users) {
        final email = user['email'] as String;
        final hasAuth = await checkUserHasAuthAccount(email);

        if (!hasAuth) {
          usersWithoutAuth.add(Map<String, dynamic>.from(user));
        }
      }

      print(
        '✅ تم العثور على ${usersWithoutAuth.length} مستخدم بدون حساب authentication',
      );
      return usersWithoutAuth;
    } catch (e) {
      print('❌ خطأ في جلب المستخدمين بدون حسابات: $e');
      throw Exception('فشل في جلب المستخدمين بدون حسابات authentication: $e');
    }
  }

  @override
  Future<bool> checkUserHasAuthAccount(String email) async {
    try {
      // محاولة البحث عن المستخدم في Auth
      final response =
          await supabaseClient
              .from('auth.users')
              .select('id')
              .eq('email', email)
              .maybeSingle();

      return response != null;
    } catch (e) {
      // إذا حدث خطأ، نفترض أن المستخدم غير موجود في Auth
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('*')
              .eq('email', email)
              .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  @override
  Future<bool> createAuthAccountForUser({
    required String email,
    required String defaultPassword,
    required String userId,
  }) async {
    try {
      print('🔐 إنشاء حساب authentication للإيميل: $email');

      // إنشاء حساب في Auth باستخدام Admin API
      final authResponse = await supabaseClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: defaultPassword,
          emailConfirm: true, // تأكيد الإيميل تلقائياً
          userMetadata: {'created_by_admin': true, 'original_user_id': userId},
        ),
      );

      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب authentication');
      }

      // ربط User ID الجديد في Auth مع User ID في قاعدة البيانات
      await supabaseClient
          .from('users')
          .update({'auth_user_id': authResponse.user!.id})
          .eq('id', userId);

      print('✅ تم إنشاء حساب authentication بنجاح للمستخدم: $email');
      return true;
    } catch (e) {
      print('❌ خطأ في إنشاء حساب authentication: $e');

      // إذا كان الخطأ أن الإيميل موجود بالفعل
      if (e.toString().contains('already registered') ||
          e.toString().contains('email_exists')) {
        print('⚠️ الإيميل موجود بالفعل في Authentication');
        return await _linkExistingAuthUser(email, userId);
      }

      throw Exception('فشل في إنشاء حساب authentication: $e');
    }
  }

  /// ربط حساب authentication موجود مع user في قاعدة البيانات
  Future<bool> _linkExistingAuthUser(String email, String userId) async {
    try {
      // البحث عن المستخدم في Auth
      final authUsers = await supabaseClient.auth.admin.listUsers();

      final authUser = authUsers.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('المستخدم غير موجود في Authentication'),
      );

      // ربط Auth User ID مع User في قاعدة البيانات
      await supabaseClient
          .from('users')
          .update({'auth_user_id': authUser.id})
          .eq('id', userId);

      print(
        '✅ تم ربط حساب authentication الموجود مع المستخدم في قاعدة البيانات',
      );
      return true;
    } catch (e) {
      print('❌ خطأ في ربط حساب authentication: $e');
      return false;
    }
  }

  /// إنشاء كلمة مرور افتراضية للمستخدم
  String _generateDefaultPassword(String email, String fullName) {
    // إنشاء كلمة مرور من أول 3 أحرف من الاسم + @ + أول 3 أحرف من الإيميل + 123
    final namePrefix =
        fullName.length >= 3 ? fullName.substring(0, 3) : fullName;
    final emailPrefix = email.split('@')[0];
    final emailPart =
        emailPrefix.length >= 3 ? emailPrefix.substring(0, 3) : emailPrefix;

    return '${namePrefix}@${emailPart}123';
  }

  /// إرسال كلمة مرور افتراضية للمستخدم عبر إشعار أو إيميل
  Future<void> sendDefaultPasswordToUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // يمكن إرسال الكلمة عبر الإشعارات في التطبيق أو إيميل
      // هنا مثال لحفظ الإشعار في قاعدة البيانات

      await supabaseClient.from('notifications').insert({
        'recipient_email': email,
        'title': 'تم إنشاء حساب دخول جديد',
        'body': '''
مرحباً $fullName،

تم إنشاء حساب دخول جديد لك في نظام نترو.

بيانات الدخول:
الإيميل: $email
كلمة المرور: $password

يرجى تغيير كلمة المرور بعد أول تسجيل دخول.

فريق نترو
        ''',
        'type': 'auth_credentials',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ تم إرسال بيانات الدخول للمستخدم: $email');
    } catch (e) {
      print('⚠️ تعذر إرسال بيانات الدخول: $e');
      // لا نرمي exception هنا لأن إنشاء الحساب نجح
    }
  }
}
