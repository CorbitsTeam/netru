import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/user_profile_detail_entity.dart';
import '../../domain/usecases/manage_users.dart';

part 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final GetAllUsers getAllUsers;
  final VerifyUser verifyUser;
  final SuspendUser suspendUser;
  final GetUserDetailedProfile getUserDetailedProfile;

  AdminUsersCubit({
    required this.getAllUsers,
    required this.verifyUser,
    required this.suspendUser,
    required this.getUserDetailedProfile,
  }) : super(AdminUsersInitial());

  Future<void> loadUsers({
    int page = 0,
    int limit = 20,
    String? search,
    AdminUserType? userType,
    VerificationStatus? verificationStatus,
    String? governorate,
  }) async {
    if (page == 0) {
      emit(AdminUsersLoading());
    } else {
      emit(AdminUsersLoadingMore());
    }

    final params = GetUsersParams(
      page: page,
      limit: limit,
      searchQuery: search,
      userType: userType,
      verificationStatus: verificationStatus,
      governorate: governorate,
    );

    final result = await getAllUsers(params);

    result.fold((failure) => emit(AdminUsersError(failure.toString())), (
      users,
    ) {
      if (page == 0) {
        emit(AdminUsersLoaded(users));
      } else {
        // Handle pagination - you might want to keep track of current users
        emit(AdminUsersLoaded(users));
      }
    });
  }

  Future<void> verifyUserById(
    String userId,
    VerificationStatus status, {
    String? notes,
  }) async {
    emit(AdminUsersVerifying());

    final params = VerifyUserParams(
      userId: userId,
      status: status,
      notes: notes,
    );

    final result = await verifyUser(params);

    result.fold((failure) => emit(AdminUsersError(failure.toString())), (
      success,
    ) async {
      if (success) {
        emit(AdminUsersVerified());
        // Force reload users immediately to get updated data
        await loadUsers();
      } else {
        emit(const AdminUsersError('فشل في تحديث حالة التحقق'));
      }
    });
  }

  Future<void> suspendUserById(
    String userId,
    bool suspend, {
    String? reason,
  }) async {
    emit(AdminUsersSuspending());

    final params = SuspendUserParams(
      userId: userId,
      suspend: suspend,
      reason: reason,
    );

    final result = await suspendUser(params);

    result.fold((failure) => emit(AdminUsersError(failure.toString())), (
      success,
    ) async {
      if (success) {
        emit(AdminUsersSuspended());
        // Force reload users immediately to get updated data
        await loadUsers();
      } else {
        emit(const AdminUsersError('فشل في تحديث حالة المستخدم'));
      }
    });
  }

  Future<void> loadUserDetailedProfile(String userId) async {
    emit(AdminUsersLoadingDetailedProfile());

    final params = GetUserDetailedProfileParams(userId: userId);
    final result = await getUserDetailedProfile(params);

    result.fold(
      (failure) {
        emit(AdminUsersError(failure.toString()));
      },
      (userDetail) {
        emit(AdminUsersDetailedProfileLoaded(userDetail));
      },
    );
  }

  Future<void> refreshUserDetailedProfile(String userId) async {
    // Refresh detailed profile without showing loading state again
    final params = GetUserDetailedProfileParams(userId: userId);
    final result = await getUserDetailedProfile(params);

    result.fold(
      (failure) {
        // Keep current state if refresh fails
      },
      (userDetail) {
        emit(AdminUsersDetailedProfileLoaded(userDetail));
      },
    );
  }

  void resetState() {
    emit(AdminUsersInitial());
  }
}
