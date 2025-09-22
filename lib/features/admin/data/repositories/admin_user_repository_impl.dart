import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/user_profile_detail_entity.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/admin_user_remote_data_source.dart';
import '../models/admin_user_model.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserRemoteDataSource remoteDataSource;

  AdminUserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAllUsers({
    int? page,
    int? limit,
    AdminUserType? userType,
    VerificationStatus? verificationStatus,
    String? searchQuery,
    String? governorate,
  }) async {
    try {
      final users = await remoteDataSource.getAllUsers(
        page: page,
        limit: limit,
        search: searchQuery,
        userType: userType?.value,
        verificationStatus: verificationStatus?.toString().split('.').last,
      );
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUserById(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUser(
    AdminUserEntity user,
  ) async {
    try {
      final userModel = AdminUserModel(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        nationalId: user.nationalId,
        passportNumber: user.passportNumber,
        userType: user.userType,
        role: user.role,
        phone: user.phone,
        governorate: user.governorate,
        city: user.city,
        district: user.district,
        address: user.address,
        nationality: user.nationality,
        profileImage: user.profileImage,
        verificationStatus: user.verificationStatus,
        verifiedAt: user.verifiedAt,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLoginAt: user.lastLoginAt,
        reportCount: user.reportCount,
        permissions: user.permissions,
      );

      final updatedUser = await remoteDataSource.updateUser(
        user.id,
        userModel.toJson(),
      );
      return Right(updatedUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyUser({
    required String userId,
    required VerificationStatus status,
    String? notes,
  }) async {
    try {
      await remoteDataSource.verifyUser(
        userId,
        approved: status == VerificationStatus.verified,
        notes: notes,
      );
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> suspendUser({
    required String userId,
    required bool suspend,
    String? reason,
  }) async {
    try {
      await remoteDataSource.updateUser(userId, {
        'is_active': !suspend,
        'suspension_reason': reason,
        'suspended_at': suspend ? DateTime.now().toIso8601String() : null,
      });
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers() async {
    try {
      final users = await remoteDataSource.getAllUsers(
        userType: AdminUserType.admin.value,
      );
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createAdminUser({
    required String email,
    required String fullName,
    required AdminRole role,
    required List<String> permissions,
  }) async {
    try {
      final userData = {
        'email': email,
        'full_name': fullName,
        'user_type': AdminUserType.admin.value,
        'role': role.value,
        'permissions': permissions,
        'verification_status':
            VerificationStatus.verified.toString().split('.').last,
        'verified_at': DateTime.now().toIso8601String(),
        'is_active': true,
      };

      final user = await remoteDataSource.updateUser('', userData);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUserRole({
    required String userId,
    required AdminRole role,
    required List<String> permissions,
  }) async {
    try {
      await remoteDataSource.updateUser(userId, {
        'role': role.value,
        'permissions': permissions,
      });
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserActivity(
    String userId,
  ) async {
    try {
      // This would need to be implemented in the remote data source
      // For now, return empty activity
      return const Right({
        'reports_count': 0,
        'last_login': null,
        'activities': [],
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserLogs({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      // This would need to be implemented in the remote data source
      // For now, return empty logs
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileDetailEntity>> getUserDetailedProfile(
    String userId,
  ) async {
    try {
      final userDetail = await remoteDataSource.getUserDetailedProfile(userId);
      return Right(userDetail);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
