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
        throw Exception('Invalid credentials or user not found');
      }

      // Handle if response is a list (TABLE return) or single object
      Map<String, dynamic> userData;
      if (response is List && response.isNotEmpty) {
        userData = response.first as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        userData = response;
      } else {
        throw Exception('Unexpected response format from login function');
      }

      return LoginUserModel.fromJson(userData);
    } catch (e) {
      if (e.toString().contains('Invalid credentials')) {
        throw Exception(
          'Invalid credentials. Please check your identifier and password.',
        );
      } else if (e.toString().contains('User not found')) {
        throw Exception('User not found. Please check your identifier.');
      } else {
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }
}
