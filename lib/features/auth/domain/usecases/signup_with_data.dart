import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signup with raw data (Map format)
/// This is used by SignupCubit for specific signup flows
class SignUpWithDataUseCase
    implements UseCase<UserEntity, SignUpWithDataParams> {
  final AuthRepository _authRepository;

  SignUpWithDataUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithDataParams params) async {
    // Convert userData Map to UserEntity
    final userData = params.userData;

    // Parse user type
    UserType userType;
    final userTypeString = userData['user_type'] as String?;
    if (userTypeString == 'citizen') {
      userType = UserType.citizen;
    } else if (userTypeString == 'foreigner') {
      userType = UserType.foreigner;
    } else {
      userType = UserType.citizen; // default
    }

    // Create UserEntity from Map data
    final user = UserEntity(
      fullName: userData['full_name'] as String? ?? '',
      nationalId: userData['national_id'] as String?,
      passportNumber: userData['passport_number'] as String?,
      userType: userType,
      email: userData['email'] as String?,
      phone: userData['phone'] as String?,
      address: userData['address'] as String?,
      verificationStatus: VerificationStatus.pending,
    );

    // Get password from userData
    final password = userData['password'] as String? ?? '';

    // Call the auth repository
    return await _authRepository.registerUser(
      user: user,
      password: password,
      documents: [],
    );
  }
}

class SignUpWithDataParams {
  final Map<String, dynamic> userData;

  SignUpWithDataParams({required this.userData});
}
