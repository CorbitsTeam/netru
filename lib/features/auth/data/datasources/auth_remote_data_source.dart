import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<UserModel> signInWithGoogle();

  Future<CitizenModel> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
    String? address,
  });

  Future<ForeignerModel> registerForeigner({
    required String email,
    required String password,
    required String fullName,
    required String passportNumber,
    required String nationality,
    required String phone,
  });

  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> isUserLoggedIn();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      // Get user profile from our custom table
      final userProfile = await _getUserProfile(response.user!.id);
      return userProfile;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      // Create user profile
      final userProfile = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        userType: UserType.egyptian, // Default
        createdAt: DateTime.now(),
      );

      await supabaseClient.from('users').insert(userProfile.toJson());

      return userProfile;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed');
      }

      // Check if user profile exists, if not create one
      final existingProfile = await _getUserProfileSafe(response.user!.id);

      if (existingProfile != null) {
        return existingProfile;
      }

      // Create new user profile
      final userProfile = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        fullName:
            response.user!.userMetadata?['full_name'] ??
            response.user!.userMetadata?['name'] ??
            'Google User',
        profileImage: response.user!.userMetadata?['avatar_url'],
        userType: UserType.egyptian, // Default
        createdAt: DateTime.now(),
      );

      await supabaseClient.from('users').insert(userProfile.toJson());

      return userProfile;
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<CitizenModel> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
    String? address,
  }) async {
    try {
      // Validate national ID format (14 digits)
      if (!_isValidEgyptianNationalId(nationalId)) {
        throw Exception('Invalid national ID format. Must be 14 digits.');
      }

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      final citizenProfile = CitizenModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        nationalId: nationalId,
        address: address,
        createdAt: DateTime.now(),
      );

      // Insert into citizens table first
      await supabaseClient.from('users').insert({
        'id': citizenProfile.id,
        'email': citizenProfile.email,
        'full_name': citizenProfile.fullName,
        'phone': citizenProfile.phone,
        'user_type': 'egyptian',
        'created_at': citizenProfile.createdAt.toIso8601String(),
      });

      // Then insert into citizens table with user_type
      final citizenData = citizenProfile.toJson();
      citizenData['user_type'] = 'egyptian';
      await supabaseClient.from('citizens').insert(citizenData);

      return citizenProfile;
    } catch (e) {
      throw Exception('Citizen registration failed: ${e.toString()}');
    }
  }

  @override
  Future<ForeignerModel> registerForeigner({
    required String email,
    required String password,
    required String fullName,
    required String passportNumber,
    required String nationality,
    required String phone,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      final foreignerProfile = ForeignerModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        passportNumber: passportNumber,
        nationality: nationality,
        createdAt: DateTime.now(),
      );

      // Insert into users table first
      await supabaseClient.from('users').insert({
        'id': foreignerProfile.id,
        'email': foreignerProfile.email,
        'full_name': foreignerProfile.fullName,
        'phone': foreignerProfile.phone,
        'user_type': 'foreigner',
        'created_at': foreignerProfile.createdAt.toIso8601String(),
      });

      // Then insert into foreigners table with user_type
      final foreignerData = foreignerProfile.toJson();
      foreignerData['user_type'] = 'foreigner';
      await supabaseClient.from('foreigners').insert(foreignerData);

      return foreignerProfile;
    } catch (e) {
      throw Exception('Foreigner registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      return await _getUserProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  Future<UserModel> _getUserProfile(String userId) async {
    final response =
        await supabaseClient.from('users').select().eq('id', userId).single();

    return UserModel.fromJson(response);
  }

  Future<UserModel?> _getUserProfileSafe(String userId) async {
    try {
      return await _getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  bool _isValidEgyptianNationalId(String nationalId) {
    // Egyptian national ID validation: exactly 14 digits
    final regex = RegExp(r'^\d{14}$');
    return regex.hasMatch(nationalId);
  }
}
