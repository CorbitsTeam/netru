import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user_entity.dart';
import '../entities/user_profile_detail_entity.dart';

abstract class AdminUserRepository {
  Future<Either<Failure, List<AdminUserEntity>>> getAllUsers({
    int? page,
    int? limit,
    AdminUserType? userType,
    VerificationStatus? verificationStatus,
    String? searchQuery,
    String? governorate,
  });

  Future<Either<Failure, AdminUserEntity>> getUserById(String userId);

  Future<Either<Failure, AdminUserEntity>> updateUser(AdminUserEntity user);

  Future<Either<Failure, bool>> verifyUser({
    required String userId,
    required VerificationStatus status,
    String? notes,
  });

  Future<Either<Failure, bool>> suspendUser({
    required String userId,
    required bool suspend,
    String? reason,
  });

  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers();

  Future<Either<Failure, AdminUserEntity>> createAdminUser({
    required String email,
    required String fullName,
    required AdminRole role,
    required List<String> permissions,
  });

  Future<Either<Failure, bool>> updateUserRole({
    required String userId,
    required AdminRole role,
    required List<String> permissions,
  });

  Future<Either<Failure, Map<String, dynamic>>> getUserActivity(String userId);

  Future<Either<Failure, List<Map<String, dynamic>>>> getUserLogs({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<Either<Failure, UserProfileDetailEntity>> getUserDetailedProfile(
    String userId,
  );
}
