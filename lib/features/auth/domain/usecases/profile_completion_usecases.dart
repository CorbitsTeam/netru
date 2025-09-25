import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'validate_critical_data.dart';

/// Use Case شامل لإكمال الملف الشخصي مع التحقق من البيانات
class CompleteProfileUseCase {
  final AuthRepository authRepository;
  final ValidateCriticalDataUseCase validateCriticalDataUseCase;

  CompleteProfileUseCase(this.authRepository, this.validateCriticalDataUseCase);

  Future<Either<Failure, UserEntity>> call(CompleteProfileParams params) async {
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

        // إذا كانت البيانات صالحة، أكمل الملف الشخصي
        return await authRepository.completeUserProfile(
          params.user,
          params.authUserId,
        );
      });
    } catch (e) {
      return Left(ServerFailure('خطأ في إكمال الملف الشخصي: ${e.toString()}'));
    }
  }
}

/// Use Case للتحقق من الإيميل وإكمال التسجيل
class VerifyEmailAndCompleteSignupUseCase {
  final AuthRepository authRepository;

  VerifyEmailAndCompleteSignupUseCase(this.authRepository);

  Future<Either<Failure, UserEntity?>> call(UserEntity userData) async {
    return await authRepository.verifyEmailAndCompleteSignup(userData);
  }
}

/// Use Case لإعادة إرسال رسالة التأكيد
class ResendVerificationEmailUseCase {
  final AuthRepository authRepository;

  ResendVerificationEmailUseCase(this.authRepository);

  Future<Either<Failure, bool>> call() async {
    return await authRepository.resendVerificationEmail();
  }
}

/// Use Case للتسجيل بالإيميل فقط (أول خطوة)
class SignUpWithEmailOnlyUseCase {
  final AuthRepository authRepository;

  SignUpWithEmailOnlyUseCase(this.authRepository);

  Future<Either<Failure, String>> call(SignUpEmailParams params) async {
    return await authRepository.signUpWithEmailOnly(
      params.email,
      params.password,
    );
  }
}

class CompleteProfileParams {
  final UserEntity user;
  final String authUserId;

  CompleteProfileParams({required this.user, required this.authUserId});
}

class SignUpEmailParams {
  final String email;
  final String password;

  SignUpEmailParams({required this.email, required this.password});
}
