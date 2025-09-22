import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_user_entity.dart';
import '../entities/user_profile_detail_entity.dart';
import '../repositories/admin_user_repository.dart';

class GetAllUsers implements UseCase<List<AdminUserEntity>, GetUsersParams> {
  final AdminUserRepository repository;

  GetAllUsers(this.repository);

  @override
  Future<Either<Failure, List<AdminUserEntity>>> call(
    GetUsersParams params,
  ) async {
    return await repository.getAllUsers(
      page: params.page,
      limit: params.limit,
      userType: params.userType,
      verificationStatus: params.verificationStatus,
      searchQuery: params.searchQuery,
      governorate: params.governorate,
    );
  }
}

class GetUserById implements UseCase<AdminUserEntity, GetUserByIdParams> {
  final AdminUserRepository repository;

  GetUserById(this.repository);

  @override
  Future<Either<Failure, AdminUserEntity>> call(
    GetUserByIdParams params,
  ) async {
    return await repository.getUserById(params.userId);
  }
}

class VerifyUser implements UseCase<bool, VerifyUserParams> {
  final AdminUserRepository repository;

  VerifyUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyUserParams params) async {
    return await repository.verifyUser(
      userId: params.userId,
      status: params.status,
      notes: params.notes,
    );
  }
}

class SuspendUser implements UseCase<bool, SuspendUserParams> {
  final AdminUserRepository repository;

  SuspendUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(SuspendUserParams params) async {
    return await repository.suspendUser(
      userId: params.userId,
      suspend: params.suspend,
      reason: params.reason,
    );
  }
}

class CreateAdminUser
    implements UseCase<AdminUserEntity, CreateAdminUserParams> {
  final AdminUserRepository repository;

  CreateAdminUser(this.repository);

  @override
  Future<Either<Failure, AdminUserEntity>> call(
    CreateAdminUserParams params,
  ) async {
    return await repository.createAdminUser(
      email: params.email,
      fullName: params.fullName,
      role: params.role,
      permissions: params.permissions,
    );
  }
}

class UpdateUserRole implements UseCase<bool, UpdateUserRoleParams> {
  final AdminUserRepository repository;

  UpdateUserRole(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateUserRoleParams params) async {
    return await repository.updateUserRole(
      userId: params.userId,
      role: params.role,
      permissions: params.permissions,
    );
  }
}

class GetUserActivity
    implements UseCase<Map<String, dynamic>, GetUserActivityParams> {
  final AdminUserRepository repository;

  GetUserActivity(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetUserActivityParams params,
  ) async {
    return await repository.getUserActivity(params.userId);
  }
}

class GetUserLogs
    implements UseCase<List<Map<String, dynamic>>, GetUserLogsParams> {
  final AdminUserRepository repository;

  GetUserLogs(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetUserLogsParams params,
  ) async {
    return await repository.getUserLogs(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetUserDetailedProfile
    implements UseCase<UserProfileDetailEntity, GetUserDetailedProfileParams> {
  final AdminUserRepository repository;

  GetUserDetailedProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileDetailEntity>> call(
    GetUserDetailedProfileParams params,
  ) async {
    return await repository.getUserDetailedProfile(params.userId);
  }
}

// Parameters classes
class GetUsersParams extends Equatable {
  final int? page;
  final int? limit;
  final AdminUserType? userType;
  final VerificationStatus? verificationStatus;
  final String? searchQuery;
  final String? governorate;

  const GetUsersParams({
    this.page,
    this.limit,
    this.userType,
    this.verificationStatus,
    this.searchQuery,
    this.governorate,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    userType,
    verificationStatus,
    searchQuery,
    governorate,
  ];
}

class GetUserByIdParams extends Equatable {
  final String userId;

  const GetUserByIdParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class VerifyUserParams extends Equatable {
  final String userId;
  final VerificationStatus status;
  final String? notes;

  const VerifyUserParams({
    required this.userId,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, status, notes];
}

class SuspendUserParams extends Equatable {
  final String userId;
  final bool suspend;
  final String? reason;

  const SuspendUserParams({
    required this.userId,
    required this.suspend,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, suspend, reason];
}

class CreateAdminUserParams extends Equatable {
  final String email;
  final String fullName;
  final AdminRole role;
  final List<String> permissions;

  const CreateAdminUserParams({
    required this.email,
    required this.fullName,
    required this.role,
    required this.permissions,
  });

  @override
  List<Object> get props => [email, fullName, role, permissions];
}

class UpdateUserRoleParams extends Equatable {
  final String userId;
  final AdminRole role;
  final List<String> permissions;

  const UpdateUserRoleParams({
    required this.userId,
    required this.role,
    required this.permissions,
  });

  @override
  List<Object> get props => [userId, role, permissions];
}

class GetUserActivityParams extends Equatable {
  final String userId;

  const GetUserActivityParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetUserLogsParams extends Equatable {
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const GetUserLogsParams({
    this.userId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, limit];
}

class GetUserDetailedProfileParams extends Equatable {
  final String userId;

  const GetUserDetailedProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
