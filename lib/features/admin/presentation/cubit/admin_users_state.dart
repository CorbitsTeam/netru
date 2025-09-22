part of 'admin_users_cubit.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoadingMore extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserEntity> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminUsersLoadingDetailedProfile extends AdminUsersState {}

class AdminUsersDetailedProfileLoaded extends AdminUsersState {
  final UserProfileDetailEntity userDetail;

  const AdminUsersDetailedProfileLoaded(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

class AdminUsersVerifying extends AdminUsersState {}

class AdminUsersVerified extends AdminUsersState {}

class AdminUsersSuspending extends AdminUsersState {}

class AdminUsersSuspended extends AdminUsersState {}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object> get props => [message];
}
