import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/manage_auth_accounts.dart';
import '../../../../core/usecases/usecase.dart';

part 'admin_auth_manager_state.dart';

class AdminAuthManagerCubit extends Cubit<AdminAuthManagerState> {
  final GetUsersWithoutAuthAccount getUsersWithoutAuthAccount;
  final CreateAuthAccountForUser createAuthAccountForUser;
  final CreateAuthAccountsForAllUsers createAuthAccountsForAllUsers;
  final CheckUserHasAuthAccount checkUserHasAuthAccount;

  AdminAuthManagerCubit({
    required this.getUsersWithoutAuthAccount,
    required this.createAuthAccountForUser,
    required this.createAuthAccountsForAllUsers,
    required this.checkUserHasAuthAccount,
  }) : super(AdminAuthManagerInitial());

  Future<void> loadUsersWithoutAuthAccount() async {
    emit(AdminAuthManagerLoading());

    final result = await getUsersWithoutAuthAccount(const NoParams());

    result.fold(
      (failure) => emit(AdminAuthManagerError(failure.toString())),
      (users) => emit(AdminAuthManagerUsersLoaded(users)),
    );
  }

  Future<void> createAuthAccountForSingleUser({
    required String email,
    required String userId,
    required String fullName,
  }) async {
    emit(AdminAuthManagerCreatingAccount());

    // إنشاء كلمة مرور افتراضية
    final defaultPassword = _generateDefaultPassword(email, fullName);

    final result = await createAuthAccountForUser(
      CreateAuthAccountParams(
        email: email,
        defaultPassword: defaultPassword,
        userId: userId,
      ),
    );

    result.fold((failure) => emit(AdminAuthManagerError(failure.toString())), (
      success,
    ) {
      if (success) {
        emit(
          AdminAuthManagerAccountCreated(
            email: email,
            password: defaultPassword,
          ),
        );
      } else {
        emit(const AdminAuthManagerError('فشل في إنشاء حساب authentication'));
      }
    });
  }

  Future<void> createAuthAccountsForAll() async {
    emit(AdminAuthManagerCreatingBulkAccounts());

    final result = await createAuthAccountsForAllUsers(const NoParams());

    result.fold((failure) => emit(AdminAuthManagerError(failure.toString())), (
      success,
    ) {
      if (success) {
        emit(AdminAuthManagerBulkAccountsCreated());
        // إعادة تحميل القائمة للتحديث
        loadUsersWithoutAuthAccount();
      } else {
        emit(const AdminAuthManagerError('فشل في إنشاء بعض الحسابات'));
      }
    });
  }

  Future<void> checkUserAuthStatus(String email) async {
    final result = await checkUserHasAuthAccount(
      CheckUserAuthParams(email: email),
    );

    result.fold(
      (failure) => emit(AdminAuthManagerError(failure.toString())),
      (hasAuth) => emit(AdminAuthManagerUserChecked(email, hasAuth)),
    );
  }

  String _generateDefaultPassword(String email, String fullName) {
    final namePrefix =
        fullName.length >= 3 ? fullName.substring(0, 3) : fullName;
    final emailPrefix = email.split('@')[0];
    final emailPart =
        emailPrefix.length >= 3 ? emailPrefix.substring(0, 3) : emailPrefix;

    return '${namePrefix}@${emailPart}123';
  }

  void resetState() {
    emit(AdminAuthManagerInitial());
  }
}
