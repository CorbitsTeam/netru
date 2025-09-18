import 'package:flutter/foundation.dart';
import 'package:netru_app/core/utils/app_shared_preferences.dart';
import 'package:netru_app/features/auth/data/models/login_user_model.dart';
import 'package:netru_app/features/auth/domain/entities/login_user_entity.dart';
import 'package:netru_app/features/auth/domain/usecases/get_user_by_id.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;

class UserDataHelper {
  static final UserDataHelper _instance = UserDataHelper._internal();

  factory UserDataHelper() {
    return _instance;
  }

  UserDataHelper._internal();

  /// Get current logged-in user data from AppPreferences
  LoginUserEntity? getCurrentUser() {
    try {
      return AppPreferences().getModel<LoginUserEntity>(
        'current_user',
        (json) => LoginUserModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error getting current user: $e', wrapWidth: 1024);
      return null;
    }
  }

  /// Save current user data to AppPreferences
  Future<void> saveCurrentUser(LoginUserEntity user) async {
    try {
      await AppPreferences().saveModel<LoginUserEntity>(
        'current_user',
        user,
        (user) => LoginUserModel.fromEntity(user).toJson(),
      );
    } catch (e) {
      debugPrint('Error saving current user: $e', wrapWidth: 1024);
    }
  }

  /// Clear current user data from AppPreferences (for logout)
  Future<void> clearCurrentUser() async {
    try {
      await AppPreferences().removeData('current_user');
    } catch (e) {
      debugPrint('Error clearing current user: $e', wrapWidth: 1024);
    }
  }

  /// Refresh user data from database and update local storage
  Future<bool> refreshUserDataFromDatabase() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser?.id == null) {
        debugPrint('No current user ID found', wrapWidth: 1024);
        return false;
      }

      // Get fresh user data from database
      final getUserUseCase = di.sl<GetUserByIdUseCase>();
      final result = await getUserUseCase(
        GetUserByIdParams(userId: currentUser!.id),
      );

      return result.fold(
        (failure) {
          debugPrint(
            'Failed to refresh user data: ${failure.message}',
            wrapWidth: 1024,
          );
          return false;
        },
        (freshUser) async {
          // Update local storage with fresh data
          await saveCurrentUser(freshUser);
          debugPrint('User data refreshed successfully', wrapWidth: 1024);
          return true;
        },
      );
    } catch (e) {
      debugPrint('Error refreshing user data: $e', wrapWidth: 1024);
      return false;
    }
  }

  /// Initialize user data on app startup - refresh from database if user is logged in
  Future<bool> initializeUserData() async {
    try {
      if (isUserLoggedIn()) {
        debugPrint(
          'User is logged in, refreshing data from database...',
          wrapWidth: 1024,
        );
        return await refreshUserDataFromDatabase();
      } else {
        debugPrint('No user logged in', wrapWidth: 1024);
        return false;
      }
    } catch (e) {
      debugPrint('Error initializing user data: $e', wrapWidth: 1024);
      return false;
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return getCurrentUser() != null;
  }

  /// Get user's full name for display
  String getUserFullName() {
    final user = getCurrentUser();
    return user?.fullName ?? 'مستخدم';
  }

  /// Get user's phone number
  String? getUserPhone() {
    final user = getCurrentUser();
    return user?.phone;
  }

  /// Get user's national ID or passport number based on user type
  String? getUserIdentifier() {
    final user = getCurrentUser();
    return user?.identifier;
  }

  /// Get user's address
  String? getUserAddress() {
    final user = getCurrentUser();
    return user?.address;
  }

  /// Get user's first name (extract from full name)
  String getUserFirstName() {
    final user = getCurrentUser();
    if (user?.fullName != null && user!.fullName.trim().isNotEmpty) {
      final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
      return nameParts.first;
    }
    return '';
  }

  String getUserLastName() {
    final user = getCurrentUser();
    if (user?.fullName != null && user!.fullName.trim().isNotEmpty) {
      final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
      return nameParts.length > 1 ? nameParts.last : '';
    }
    return '';
  }

  /// Get user's national ID (for citizens)
  String? getUserNationalId() {
    final user = getCurrentUser();
    debugPrint("user : $user", wrapWidth: 1024);
    return user?.nationalId;
  }

  /// Get user's ID
  String? getUserId() {
    final user = getCurrentUser();
    return user?.id;
  }

  /// Get user's verification status
  VerificationStatus? getUserVerificationStatus() {
    final user = getCurrentUser();
    return user?.verificationStatus;
  }

  /// Get user type
  UserType? getUserType() {
    final user = getCurrentUser();
    return user?.userType;
  }

  /// Get user profile image URL
  String? getUserProfileImage() {
    final user = getCurrentUser();
    return user?.profileImage;
  }
}
