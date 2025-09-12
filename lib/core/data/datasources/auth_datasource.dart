import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/auth_session_model.dart';
import '../../services/logger_service.dart';

abstract class AuthDataSource {
  Future<AuthSessionModel> signInWithEmail(String email, String password);
  Future<AuthSessionModel> signUpWithEmail(String email, String password);
  Future<AuthSessionModel> signInWithGoogle();
  Future<AuthSessionModel> signInWithApple();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<AuthSessionModel?> getCurrentSession();
  Future<void> sendPasswordResetEmail(String email);
  Future<AuthSessionModel> refreshSession();
  Stream<UserModel?> get authStateChanges;
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient _supabase;
  final LoggerService _logger = LoggerService();

  AuthDataSourceImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<AuthSessionModel> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      _logger.logAuthEvent('Sign in with email attempt', {'email': email});

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Failed to sign in: No session returned');
      }

      _logger.logAuthEvent('Sign in with email successful', {
        'userId': response.user?.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': response.session!.accessToken,
        'refresh_token': response.session!.refreshToken,
        'token_type': response.session!.tokenType,
        'expires_in': response.session!.expiresIn,
        'expires_at': response.session!.expiresAt,
        'user': {'id': response.user!.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Sign in with email failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<AuthSessionModel> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      _logger.logAuthEvent('Sign up with email attempt', {'email': email});

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Failed to sign up: No session returned');
      }

      _logger.logAuthEvent('Sign up with email successful', {
        'userId': response.user?.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': response.session!.accessToken,
        'refresh_token': response.session!.refreshToken,
        'token_type': response.session!.tokenType,
        'expires_in': response.session!.expiresIn,
        'expires_at': response.session!.expiresAt,
        'user': {'id': response.user!.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Sign up with email failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<AuthSessionModel> signInWithGoogle() async {
    try {
      _logger.logAuthEvent('Sign in with Google attempt');

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'your-app://auth/callback',
      );

      if (!response) {
        throw Exception('Failed to initiate Google sign in');
      }

      // Wait for auth state change
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Failed to get session after Google sign in');
      }

      _logger.logAuthEvent('Sign in with Google successful', {
        'userId': session.user.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'token_type': session.tokenType,
        'expires_in': session.expiresIn,
        'expires_at': session.expiresAt,
        'user': {'id': session.user.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Sign in with Google failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<AuthSessionModel> signInWithApple() async {
    try {
      _logger.logAuthEvent('Sign in with Apple attempt');

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'your-app://auth/callback',
      );

      if (!response) {
        throw Exception('Failed to initiate Apple sign in');
      }

      // Wait for auth state change
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Failed to get session after Apple sign in');
      }

      _logger.logAuthEvent('Sign in with Apple successful', {
        'userId': session.user.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'token_type': session.tokenType,
        'expires_in': session.expiresIn,
        'expires_at': session.expiresAt,
        'user': {'id': session.user.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Sign in with Apple failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.logAuthEvent('Sign out attempt');

      await _supabase.auth.signOut();

      _logger.logAuthEvent('Sign out successful');
    } catch (e) {
      _logger.logAuthEvent('Sign out failed', {'error': e.toString()});
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _logger.logAuthEvent('No current user');
        return null;
      }

      _logger.logAuthEvent('Current user retrieved', {'userId': user.id});

      return UserModel.fromJson(user.toJson());
    } catch (e) {
      _logger.logAuthEvent('Get current user failed', {'error': e.toString()});
      rethrow;
    }
  }

  @override
  Future<AuthSessionModel?> getCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _logger.logAuthEvent('No current session');
        return null;
      }

      _logger.logAuthEvent('Current session retrieved', {
        'userId': session.user.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'token_type': session.tokenType,
        'expires_in': session.expiresIn,
        'expires_at': session.expiresAt,
        'user': {'id': session.user.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Get current session failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.logAuthEvent('Password reset email attempt', {'email': email});

      await _supabase.auth.resetPasswordForEmail(email);

      _logger.logAuthEvent('Password reset email sent', {'email': email});
    } catch (e) {
      _logger.logAuthEvent('Password reset email failed', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<AuthSessionModel> refreshSession() async {
    try {
      _logger.logAuthEvent('Refresh session attempt');

      final response = await _supabase.auth.refreshSession();

      if (response.session == null) {
        throw Exception('Failed to refresh session: No session returned');
      }

      _logger.logAuthEvent('Refresh session successful', {
        'userId': response.user?.id,
      });

      return AuthSessionModel.fromJson({
        'access_token': response.session!.accessToken,
        'refresh_token': response.session!.refreshToken,
        'token_type': response.session!.tokenType,
        'expires_in': response.session!.expiresIn,
        'expires_at': response.session!.expiresAt,
        'user': {'id': response.user!.id},
      });
    } catch (e) {
      _logger.logAuthEvent('Refresh session failed', {'error': e.toString()});
      rethrow;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) {
        _logger.logAuthEvent('Auth state changed: signed out');
        return null;
      }

      _logger.logAuthEvent('Auth state changed: signed in', {
        'userId': user.id,
      });
      return UserModel.fromJson(user.toJson());
    });
  }
}
