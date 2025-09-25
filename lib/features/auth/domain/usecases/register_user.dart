import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'validate_critical_data.dart';

/// Use Case لتسجيل مستخدم جديد مع التحقق الشامل من البيانات الحساسة
class RegisterUserUseCase {
  final AuthRepository authRepository;
  final ValidateCriticalDataUseCase validateCriticalDataUseCase;

  RegisterUserUseCase(this.authRepository, this.validateCriticalDataUseCase);

  Future<Either<Failure, UserEntity>> call(RegisterUserParams params) async {
    try {
      // أولاً: التحقق من البيانات الحساسة
      final validationResult = await validateCriticalDataUseCase.call(
        email: params.user.email,
        phone: params.user.phone,
        nationalId: params.user.nationalId,
        passportNumber: params.user.passportNumber,
      );

      // التحقق من نتيجة التحقق
      return await validationResult.fold((failure) async => Left(failure), (
        result,
      ) async {
        if (result.hasErrors) {
          return Left(ServerFailure(result.firstError));
        }

        // إذا كانت البيانات صالحة، تابع مع التسجيل
        return await authRepository.registerUser(
          user: params.user,
          password: params.password,
          documents: params.documents,
        );
      });
    } catch (e) {
      return Left(ServerFailure('خطأ في تسجيل المستخدم: ${e.toString()}'));
    }
  }
}

class RegisterUserParams {
  final UserEntity user;
  final String password;
  final List<File>? documents;

  RegisterUserParams({
    required this.user,
    required this.password,
    this.documents,
  });
}
