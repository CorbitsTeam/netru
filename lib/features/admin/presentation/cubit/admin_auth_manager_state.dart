part of 'admin_auth_manager_cubit.dart';

abstract class AdminAuthManagerState extends Equatable {
  const AdminAuthManagerState();

  @override
  List<Object?> get props => [];
}

class AdminAuthManagerInitial extends AdminAuthManagerState {}

class AdminAuthManagerLoading extends AdminAuthManagerState {}

class AdminAuthManagerUsersLoaded extends AdminAuthManagerState {
  final List<Map<String, dynamic>> usersWithoutAuth;

  const AdminAuthManagerUsersLoaded(this.usersWithoutAuth);

  @override
  List<Object?> get props => [usersWithoutAuth];
}

class AdminAuthManagerCreatingAccount extends AdminAuthManagerState {}

class AdminAuthManagerAccountCreated extends AdminAuthManagerState {
  final String email;
  final String password;

  const AdminAuthManagerAccountCreated({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AdminAuthManagerCreatingBulkAccounts extends AdminAuthManagerState {}

class AdminAuthManagerBulkAccountsCreated extends AdminAuthManagerState {}

class AdminAuthManagerUserChecked extends AdminAuthManagerState {
  final String email;
  final bool hasAuthAccount;

  const AdminAuthManagerUserChecked(this.email, this.hasAuthAccount);

  @override
  List<Object?> get props => [email, hasAuthAccount];
}

class AdminAuthManagerError extends AdminAuthManagerState {
  final String message;

  const AdminAuthManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
