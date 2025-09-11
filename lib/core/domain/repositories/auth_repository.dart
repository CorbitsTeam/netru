import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/user.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> signInWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, AuthSession>> signUpWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, AuthSession>> signInWithGoogle();
  Future<Either<Failure, AuthSession>> signInWithApple();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, AuthSession?>> getCurrentSession();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, AuthSession>> refreshSession();
  Stream<User?> get authStateChanges;
}
