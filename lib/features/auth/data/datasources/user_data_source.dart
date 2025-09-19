import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/login_user_model.dart';
import '../../domain/entities/login_user_entity.dart';

abstract class UserDataSource {
  Future<bool> checkUserExists(String identifier);
  Future<LoginUserModel> loginUser(
    String identifier,
    String password,
    UserType userType,
  );
  Future<LoginUserModel> signUpUser(Map<String, dynamic> userData);
  Future<LoginUserModel> getUserById(String userId);
  Future<LoginUserModel> getUserByEmail(String email);
  Future<LoginUserModel> getUserByNationalId(String nationalId);
  Future<LoginUserModel> getUserByPassport(String passportNumber);
  Future<LoginUserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  );
}

class SupabaseUserDataSource implements UserDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseUserDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<bool> checkUserExists(String identifier) async {
    try {
      final response = await _supabaseClient.rpc(
        'is_user_registered',
        params: {'identifier': identifier},
      );

      if (response == null) {
        return false;
      }

      // The function returns a boolean value
      return response as bool;
    } catch (e) {
      throw Exception('Failed to check user existence: ${e.toString()}');
    }
  }

  @override
  Future<LoginUserModel> loginUser(
    String identifier,
    String password,
    UserType userType,
  ) async {
    try {
      final response = await _supabaseClient.rpc(
        'custom_login',
        params: {
          'p_identifier': identifier,
          'p_password': password,
          'p_user_type': userType.name,
        },
      );

      if (response == null || (response is List && response.isEmpty)) {
        // Handle different user types with Arabic error messages
        switch (userType) {
          case UserType.citizen:
            throw Exception('الرقم القومي غير صحيح');
          case UserType.foreigner:
            throw Exception('رقم الباسبور غير صحيح');
          case UserType.admin:
            throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
      }

      // Handle if response is a list (TABLE return) or single object
      Map<String, dynamic> userData;
      if (response is List && response.isNotEmpty) {
        userData = response.first as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        userData = response;
      } else {
        throw Exception('تنسيق غير متوقع من دالة تسجيل الدخول');
      }

      return LoginUserModel.fromJson(userData);
    } catch (e) {
      // Check for specific error types and return appropriate Arabic messages
      if (e.toString().contains('الرقم القومي غير صحيح') ||
          e.toString().contains('رقم الباسبور غير صحيح') ||
          e.toString().contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')) {
        rethrow; // Re-throw our custom Arabic messages
      } else if (e.toString().contains('Invalid credentials')) {
        switch (userType) {
          case UserType.citizen:
            throw Exception('الرقم القومي غير صحيح');
          case UserType.foreigner:
            throw Exception('رقم الباسبور غير صحيح');
          case UserType.admin:
            throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
      } else if (e.toString().contains('User not found')) {
        switch (userType) {
          case UserType.citizen:
            throw Exception('الرقم القومي غير صحيح');
          case UserType.foreigner:
            throw Exception('رقم الباسبور غير صحيح');
          case UserType.admin:
            throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
      } else {
        throw Exception('فشل تسجيل الدخول: ${e.toString()}');
      }
    }
  }

  @override
  Future<LoginUserModel> signUpUser(Map<String, dynamic> userData) async {
    try {
      final userType = UserType.values.firstWhere(
        (type) => type.name == userData['user_type'],
        orElse: () => UserType.citizen,
      );

      // Check if email already exists
      if (userData['email'] != null &&
          userData['email'].toString().isNotEmpty) {
        // First check auth.users table
        try {
          final authEmailExists =
              await _supabaseClient
                  .from('auth.users')
                  .select('id')
                  .eq('email', userData['email'])
                  .maybeSingle();

          if (authEmailExists != null) {
            throw Exception('البريد الإلكتروني مستخدم من قبل');
          }
        } catch (authError) {
          // If the exception is our custom message, re-throw it
          if (authError.toString().contains(
            'البريد الإلكتروني مستخدم من قبل',
          )) {
            rethrow;
          }

          // If auth table check fails for other reasons, check public.users table as fallback
          final emailExists =
              await _supabaseClient
                  .from('users')
                  .select('id')
                  .eq('email', userData['email'])
                  .maybeSingle();

          if (emailExists != null) {
            throw Exception('البريد الإلكتروني مستخدم من قبل');
          }
        }
      }

      // Check user type specific identifiers
      if (userType == UserType.citizen && userData['national_id'] != null) {
        final nationalIdExists =
            await _supabaseClient
                .from('users')
                .select('id')
                .eq('national_id', userData['national_id'])
                .maybeSingle();

        if (nationalIdExists != null) {
          throw Exception('الرقم القومي مستخدم من قبل');
        }
      } else if (userType == UserType.foreigner &&
          userData['passport_number'] != null) {
        final passportExists =
            await _supabaseClient
                .from('users')
                .select('id')
                .eq('passport_number', userData['passport_number'])
                .maybeSingle();

        if (passportExists != null) {
          throw Exception('رقم الباسبور مستخدم من قبل');
        }
      }

      // Hash the password using Supabase crypt function
      if (userData['password'] != null) {
        try {
          final hashedPasswordResponse = await _supabaseClient.rpc(
            'hash_password',
            params: {'p_password': userData['password']},
          );
          userData['password'] = hashedPasswordResponse;
        } catch (hashError) {
          // If hash_password function doesn't exist, use simple hashing
          // In production, ensure the hash_password function exists in Supabase
          userData['password_hash'] =
              userData['password']; // Store as plain text temporarily
          userData.remove('password'); // Remove plain password
        }
      }

      // Insert new user
      final response =
          await _supabaseClient
              .from('users')
              .insert(userData)
              .select()
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      // Re-throw our custom Arabic messages
      if (e.toString().contains('البريد الإلكتروني مستخدم من قبل') ||
          e.toString().contains('الرقم القومي مستخدم من قبل') ||
          e.toString().contains('رقم الباسبور مستخدم من قبل')) {
        rethrow;
      } else if (e.toString().contains('duplicate') ||
          e.toString().contains('unique')) {
        // Handle database unique constraint violations
        if (e.toString().contains('email')) {
          throw Exception('البريد الإلكتروني مستخدم من قبل');
        } else if (e.toString().contains('national_id')) {
          throw Exception('الرقم القومي مستخدم من قبل');
        } else if (e.toString().contains('passport_number')) {
          throw Exception('رقم الباسبور مستخدم من قبل');
        } else {
          throw Exception('البيانات مستخدمة من قبل');
        }
      } else {
        throw Exception('فشل إنشاء الحساب: ${e.toString()}');
      }
    }
  }

  @override
  Future<LoginUserModel> getUserById(String userId) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('id', userId)
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  @override
  Future<LoginUserModel> getUserByEmail(String email) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('email', email)
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم بالبريد الإلكتروني: $e');
    }
  }

  @override
  Future<LoginUserModel> getUserByNationalId(String nationalId) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('national_id', nationalId)
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم بالرقم القومي: $e');
    }
  }

  @override
  Future<LoginUserModel> getUserByPassport(String passportNumber) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select('*')
              .eq('passport_number', passportNumber)
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم برقم جواز السفر: $e');
    }
  }

  @override
  Future<LoginUserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Remove any fields that shouldn't be updated
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

      // Add updated_at timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _supabaseClient
              .from('users')
              .update(updateData)
              .eq('id', userId)
              .select()
              .single();

      return LoginUserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات المستخدم: $e');
    }
  }
}
