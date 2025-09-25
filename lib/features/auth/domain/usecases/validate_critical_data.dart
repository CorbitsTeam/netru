import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use Case للتحقق الشامل من البيانات الحساسة
/// يتحقق من الإيميل، رقم التليفون، والرقم القومي/جواز السفر
class ValidateCriticalDataUseCase {
  final AuthRepository authRepository;

  ValidateCriticalDataUseCase(this.authRepository);

  /// التحقق من البيانات الحساسة
  /// [email] - البريد الإلكتروني (اختياري)
  /// [phone] - رقم التليفون (اختياري)
  /// [nationalId] - الرقم القومي (اختياري)
  /// [passportNumber] - رقم جواز السفر (اختياري)
  ///
  /// يعود بـ ValidationResult يحتوي على تفاصيل التحقق
  Future<Either<Failure, ValidationResult>> call({
    String? email,
    String? phone,
    String? nationalId,
    String? passportNumber,
  }) async {
    try {
      final validationResult = ValidationResult();

      // التحقق من الإيميل
      if (email != null && email.isNotEmpty) {
        final emailExistsInUsers = await authRepository.checkEmailExistsInUsers(
          email,
        );
        emailExistsInUsers.fold(
          (failure) =>
              validationResult.addError('خطأ في التحقق من البريد الإلكتروني'),
          (exists) {
            if (exists) {
              validationResult.addError('البريد الإلكتروني مستخدم من قبل');
            }
          },
        );
      }

      // التحقق من رقم التليفون
      if (phone != null && phone.isNotEmpty) {
        final phoneExists = await authRepository.checkPhoneExists(phone);
        phoneExists.fold(
          (failure) =>
              validationResult.addError('خطأ في التحقق من رقم التليفون'),
          (exists) {
            if (exists) {
              validationResult.addError('رقم التليفون مستخدم من قبل');
            }
          },
        );
      }

      // التحقق من الرقم القومي
      if (nationalId != null && nationalId.isNotEmpty) {
        final nationalIdExists = await authRepository.checkNationalIdExists(
          nationalId,
        );
        nationalIdExists.fold(
          (failure) =>
              validationResult.addError('خطأ في التحقق من الرقم القومي'),
          (exists) {
            if (exists) {
              validationResult.addError('الرقم القومي مستخدم من قبل');
            }
          },
        );
      }

      // التحقق من رقم جواز السفر
      if (passportNumber != null && passportNumber.isNotEmpty) {
        final passportExists = await authRepository.checkPassportExists(
          passportNumber,
        );
        passportExists.fold(
          (failure) =>
              validationResult.addError('خطأ في التحقق من رقم جواز السفر'),
          (exists) {
            if (exists) {
              validationResult.addError('رقم جواز السفر مستخدم من قبل');
            }
          },
        );
      }

      return Right(validationResult);
    } catch (e) {
      return Left(ServerFailure('خطأ في التحقق من البيانات: ${e.toString()}'));
    }
  }
}

/// نتيجة التحقق من البيانات
class ValidationResult {
  final List<String> _errors = [];

  List<String> get errors => _errors;

  bool get isValid => _errors.isEmpty;

  bool get hasErrors => _errors.isNotEmpty;

  String get firstError => _errors.isNotEmpty ? _errors.first : '';

  String get allErrorsMessage => _errors.join('\n');

  void addError(String error) {
    if (!_errors.contains(error)) {
      _errors.add(error);
    }
  }

  void clearErrors() {
    _errors.clear();
  }
}
