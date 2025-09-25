import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use Case للتحقق من وجود البريد الإلكتروني في نظام المصادقة
class CheckEmailExistsInAuthUseCase {
  final AuthRepository authRepository;

  CheckEmailExistsInAuthUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String email) async {
    return await authRepository.checkEmailExistsInAuth(email);
  }
}

/// Use Case للتحقق من وجود البريد الإلكتروني في جدول المستخدمين
class CheckEmailExistsInUsersUseCase {
  final AuthRepository authRepository;

  CheckEmailExistsInUsersUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String email) async {
    return await authRepository.checkEmailExistsInUsers(email);
  }
}

/// Use Case للتحقق من وجود رقم التليفون
class CheckPhoneExistsUseCase {
  final AuthRepository authRepository;

  CheckPhoneExistsUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String phone) async {
    return await authRepository.checkPhoneExists(phone);
  }
}

/// Use Case للتحقق من وجود الرقم القومي
class CheckNationalIdExistsUseCase {
  final AuthRepository authRepository;

  CheckNationalIdExistsUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String nationalId) async {
    return await authRepository.checkNationalIdExists(nationalId);
  }
}

/// Use Case للتحقق من وجود رقم جواز السفر
class CheckPassportExistsUseCase {
  final AuthRepository authRepository;

  CheckPassportExistsUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String passportNumber) async {
    return await authRepository.checkPassportExists(passportNumber);
  }
}

/// Use Case عام للتحقق من وجود المستخدم بأي طريقة
class CheckUserExistsUseCase {
  final AuthRepository authRepository;

  CheckUserExistsUseCase(this.authRepository);

  Future<Either<Failure, bool>> call(String identifier) async {
    return await authRepository.checkUserExists(identifier);
  }
}
