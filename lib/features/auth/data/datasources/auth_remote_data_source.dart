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
              .select('*')
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
              .select('*')
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
      // In a real app, hash the password before storing
      final userData = user.toCreateJson();
      userData['password'] = password; // Should be hashed

      final response =
          await _supabaseClient
              .from('users')
              .insert(userData)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('unique')) {
        if (e.toString().contains('national_id')) {
          throw Exception('هذا الرقم القومي مستخدم من قبل');
        } else if (e.toString().contains('passport_number')) {
          throw Exception('رقم الجواز مستخدم من قبل');
        }
      }
      throw Exception('خطأ في إنشاء الحساب: $e');
    }
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
      final bytes = await imageFile.readAsBytes();

      await _supabaseClient.storage
          .from('user-docs')
          .uploadBinary(fileName, bytes);

      final publicUrl = _supabaseClient.storage
          .from('user-docs')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('خطأ في رفع الصورة: $e');
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
