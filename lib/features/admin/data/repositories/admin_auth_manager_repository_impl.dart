import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/manage_auth_accounts.dart';
import '../datasources/admin_auth_manager_data_source.dart';

class AdminAuthManagerRepositoryImpl implements AdminAuthManagerRepository {
  final AdminUserRemoteDataSource remoteDataSource;

  AdminAuthManagerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getUsersWithoutAuthAccount() async {
    try {
      final result = await remoteDataSource.getUsersWithoutAuthAccount();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createAuthAccountForUser({
    required String email,
    required String defaultPassword,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.createAuthAccountForUser(
        email: email,
        defaultPassword: defaultPassword,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserHasAuthAccount(String email) async {
    try {
      final result = await remoteDataSource.checkUserHasAuthAccount(email);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserByEmail(
    String email,
  ) async {
    try {
      final result = await remoteDataSource.getUserByEmail(email);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createAuthAccountsForAllUsers() async {
    try {
      // جلب جميع المستخدمين بدون حسابات auth
      final usersWithoutAuth =
          await remoteDataSource.getUsersWithoutAuthAccount();

      bool allSuccessful = true;
      int successCount = 0;

      for (final user in usersWithoutAuth) {
        try {
          // إنشاء كلمة مرور افتراضية
          final defaultPassword = _generateDefaultPassword(
            user['email'],
            user['full_name'] ?? 'User',
          );

          final success = await remoteDataSource.createAuthAccountForUser(
            email: user['email'],
            defaultPassword: defaultPassword,
            userId: user['id'],
          );

          if (success) {
            successCount++;
          } else {
            allSuccessful = false;
          }
        } catch (e) {
          print('خطأ في إنشاء حساب للمستخدم ${user['email']}: $e');
          allSuccessful = false;
        }
      }

      print('✅ تم إنشاء $successCount حساب من أصل ${usersWithoutAuth.length}');
      return Right(allSuccessful);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _generateDefaultPassword(String email, String fullName) {
    // إنشاء كلمة مرور افتراضية
    final namePrefix =
        fullName.length >= 3 ? fullName.substring(0, 3) : fullName;
    final emailPrefix = email.split('@')[0];
    final emailPart =
        emailPrefix.length >= 3 ? emailPrefix.substring(0, 3) : emailPrefix;

    return '${namePrefix}@${emailPart}123';
  }
}
