import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Check if user is currently authenticated
  static bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Sign in with Google
  static Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update user password
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Update user email
  static Future<UserResponse> updateEmail(String newEmail) async {
    return await _supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Validate Egyptian National ID
  static bool isValidEgyptianNationalId(String nationalId) {
    // Egyptian national ID validation: exactly 14 digits
    if (nationalId.length != 14) return false;

    // Check if all characters are digits
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) return false;

    // Extract birth date (characters 1-6)
    String birthDateStr = nationalId.substring(1, 7);
    int century = int.parse(nationalId.substring(0, 1));

    // Determine century
    String fullYear;
    if (century == 2) {
      fullYear = '19$birthDateStr';
    } else if (century == 3) {
      fullYear = '20$birthDateStr';
    } else {
      return false; // Invalid century
    }

    // Validate date format (YYMMDD)
    try {
      int year = int.parse(fullYear.substring(0, 4));
      int month = int.parse(fullYear.substring(4, 6));
      int day = int.parse(fullYear.substring(6, 8));

      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Check if date is valid
      DateTime birthDate = DateTime(year, month, day);
      if (birthDate.isAfter(DateTime.now())) return false;
    } catch (e) {
      return false;
    }

    // Validate governorate code (characters 7-8)
    int governorateCode = int.parse(nationalId.substring(7, 9));
    if (governorateCode < 1 || governorateCode > 35) return false;

    return true;
  }

  // Validate Egyptian phone number
  static bool isValidEgyptianPhone(String phone) {
    // Egyptian phone number format: 01[0125]XXXXXXXX
    return RegExp(r'^01[0125]\d{8}$').hasMatch(phone);
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(password)) return false;

    return true;
  }

  // Get error message in Arabic
  static String getArabicErrorMessage(String error) {
    switch (error.toLowerCase()) {
      case 'invalid_credentials':
      case 'invalid login credentials':
        return 'بيانات الدخول غير صحيحة';
      case 'email_not_confirmed':
        return 'يرجى تأكيد البريد الإلكتروني أولاً';
      case 'user_not_found':
        return 'المستخدم غير موجود';
      case 'too_many_requests':
        return 'تم تجاوز عدد المحاولات المسموح';
      case 'weak_password':
        return 'كلمة المرور ضعيفة جداً';
      case 'email_already_registered':
      case 'user_already_registered':
        return 'البريد الإلكتروني مسجل مسبقاً';
      case 'network_error':
        return 'خطأ في الاتصال بالإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
