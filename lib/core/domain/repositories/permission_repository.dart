import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/permission.dart';

abstract class PermissionRepository {
  Future<Either<Failure, Permission>> checkPermission(PermissionType type);
  Future<Either<Failure, Permission>> requestPermission(PermissionType type);
  Future<Either<Failure, List<Permission>>> requestMultiplePermissions(
    List<PermissionType> types,
  );
  Future<Either<Failure, bool>> openAppSettings();
  Future<Either<Failure, List<Permission>>> getAllPermissionsStatus();
}
