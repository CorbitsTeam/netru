import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/permission.dart';
import '../repositories/permission_repository.dart';
import 'usecase.dart';

class CheckPermissionUseCase extends UseCase<Permission, PermissionType> {
  final PermissionRepository repository;

  CheckPermissionUseCase(this.repository);

  @override
  Future<Either<Failure, Permission>> call(PermissionType params) async {
    return await repository.checkPermission(params);
  }
}

class RequestPermissionUseCase extends UseCase<Permission, PermissionType> {
  final PermissionRepository repository;

  RequestPermissionUseCase(this.repository);

  @override
  Future<Either<Failure, Permission>> call(PermissionType params) async {
    return await repository.requestPermission(params);
  }
}

class RequestMultiplePermissionsUseCase
    extends UseCase<List<Permission>, List<PermissionType>> {
  final PermissionRepository repository;

  RequestMultiplePermissionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Permission>>> call(
    List<PermissionType> params,
  ) async {
    return await repository.requestMultiplePermissions(params);
  }
}

class OpenAppSettingsUseCase extends UseCase<bool, NoParams> {
  final PermissionRepository repository;

  OpenAppSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.openAppSettings();
  }
}

class GetAllPermissionsStatusUseCase
    extends UseCase<List<Permission>, NoParams> {
  final PermissionRepository repository;

  GetAllPermissionsStatusUseCase(this.repository);

  @override
  Future<Either<Failure, List<Permission>>> call(NoParams params) async {
    return await repository.getAllPermissionsStatus();
  }
}
