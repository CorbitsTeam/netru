import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

abstract class AdminAuthManagerRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getUsersWithoutAuthAccount();
  Future<Either<Failure, bool>> createAuthAccountForUser({
    required String email,
    required String defaultPassword,
    required String userId,
  });
  Future<Either<Failure, bool>> checkUserHasAuthAccount(String email);
  Future<Either<Failure, Map<String, dynamic>>> getUserByEmail(String email);
  Future<Either<Failure, bool>> createAuthAccountsForAllUsers();
}

class GetUsersWithoutAuthAccount
    implements UseCase<List<Map<String, dynamic>>, NoParams> {
  final AdminAuthManagerRepository repository;

  GetUsersWithoutAuthAccount(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    NoParams params,
  ) async {
    return await repository.getUsersWithoutAuthAccount();
  }
}

class CreateAuthAccountForUser
    implements UseCase<bool, CreateAuthAccountParams> {
  final AdminAuthManagerRepository repository;

  CreateAuthAccountForUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(CreateAuthAccountParams params) async {
    return await repository.createAuthAccountForUser(
      email: params.email,
      defaultPassword: params.defaultPassword,
      userId: params.userId,
    );
  }
}

class CreateAuthAccountsForAllUsers implements UseCase<bool, NoParams> {
  final AdminAuthManagerRepository repository;

  CreateAuthAccountsForAllUsers(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.createAuthAccountsForAllUsers();
  }
}

class CreateAuthAccountParams {
  final String email;
  final String defaultPassword;
  final String userId;

  CreateAuthAccountParams({
    required this.email,
    required this.defaultPassword,
    required this.userId,
  });
}

class CheckUserHasAuthAccount implements UseCase<bool, CheckUserAuthParams> {
  final AdminAuthManagerRepository repository;

  CheckUserHasAuthAccount(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckUserAuthParams params) async {
    return await repository.checkUserHasAuthAccount(params.email);
  }
}

class CheckUserAuthParams {
  final String email;

  CheckUserAuthParams({required this.email});
}
