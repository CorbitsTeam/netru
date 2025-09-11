import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';
import '../datasources/auth_datasource.dart';
import '../../services/logger_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  final LoggerService _logger = LoggerService();

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, AuthSession>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await dataSource.signInWithEmail(email, password);
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in signInWithEmail', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in signInWithEmail', e);
      return const Left(
        ServerFailure('Failed to sign in with email'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthSession>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await dataSource.signUpWithEmail(email, password);
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in signUpWithEmail', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in signUpWithEmail', e);
      return const Left(
        ServerFailure('Failed to sign up with email'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthSession>> signInWithGoogle() async {
    try {
      final result = await dataSource.signInWithGoogle();
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in signInWithGoogle', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in signInWithGoogle', e);
      return const Left(
        ServerFailure('Failed to sign in with Google'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthSession>> signInWithApple() async {
    try {
      final result = await dataSource.signInWithApple();
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in signInWithApple', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in signInWithApple', e);
      return const Left(
        ServerFailure('Failed to sign in with Apple'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in signOut', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in signOut', e);
      return const Left(
        ServerFailure('Failed to sign out'),
      );
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final result = await dataSource.getCurrentUser();
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in getCurrentUser', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in getCurrentUser', e);
      return const Left(
        ServerFailure('Failed to get current user'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthSession?>> getCurrentSession() async {
    try {
      final result = await dataSource.getCurrentSession();
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in getCurrentSession', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in getCurrentSession', e);
      return const Left(
        ServerFailure('Failed to get current session'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await dataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in sendPasswordResetEmail', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in sendPasswordResetEmail', e);
      return const Left(
        ServerFailure(
          message: 'Failed to send password reset email',
          code: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    try {
      final result = await dataSource.refreshSession();
      return Right(result);
    } on ServerException catch (e) {
      _logger.logError('Auth Exception in refreshSession', e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.logError('Unexpected error in refreshSession', e);
      return const Left(
        ServerFailure('Failed to refresh session'),
      );
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return dataSource.authStateChanges;
  }
}
