import 'package:dartz/dartz.dart';
import '../../domain/entities/permission.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';
import '../datasources/permission_datasource.dart';
import '../../services/logger_service.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionDataSource dataSource;
  final LoggerService _logger = LoggerService();

  PermissionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Permission>> checkPermission(
    PermissionType type,
  ) async {
    try {
      final result = await dataSource.checkPermission(type);
      return Right(result);
    } on PermissionException catch (e) {
      _logger.logError('Permission Exception in checkPermission', e);
      return Left(PermissionFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in checkPermission', e);
      return Left(
        PermissionFailure('Failed to check permission'),
      );
    }
  }

  @override
  Future<Either<Failure, Permission>> requestPermission(
    PermissionType type,
  ) async {
    try {
      final result = await dataSource.requestPermission(type);
      return Right(result);
    } on PermissionException catch (e) {
      _logger.logError('Permission Exception in requestPermission', e);
      return Left(PermissionFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in requestPermission', e);
      return Left(
        PermissionFailure('Failed to request permission'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Permission>>> requestMultiplePermissions(
    List<PermissionType> types,
  ) async {
    try {
      final result = await dataSource.requestMultiplePermissions(types);
      return Right(result.cast<Permission>());
    } on PermissionException catch (e) {
      _logger.logError('Permission Exception in requestMultiplePermissions', e);
      return Left(PermissionFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in requestMultiplePermissions', e);
      return Left(
        PermissionFailure(
          message: 'Failed to request multiple permissions',
          code: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> openAppSettings() async {
    try {
      final result = await dataSource.openAppSettings();
      return Right(result);
    } on PermissionException catch (e) {
      _logger.logError('Permission Exception in openAppSettings', e);
      return Left(PermissionFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in openAppSettings', e);
      return Left(
        PermissionFailure('Failed to open app settings'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Permission>>> getAllPermissionsStatus() async {
    try {
      final result = await dataSource.getAllPermissionsStatus();
      return Right(result.cast<Permission>());
    } on PermissionException catch (e) {
      _logger.logError('Permission Exception in getAllPermissionsStatus', e);
      return Left(PermissionFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in getAllPermissionsStatus', e);
      return Left(
        PermissionFailure(
          message: 'Failed to get all permissions status',
          code: 500,
        ),
      );
    }
  }
}
