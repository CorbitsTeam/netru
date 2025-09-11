import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/error/failures.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import '../repositories/verification_repository.dart';

class CheckVerificationStatusUseCase
    implements UseCase<bool, CheckVerificationStatusParams> {
  final VerificationRepository repository;

  CheckVerificationStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    CheckVerificationStatusParams params,
  ) async {
    return await repository.hasVerifiedIdentity(params.userId);
  }
}

class CheckVerificationStatusParams extends Equatable {
  final String userId;

  const CheckVerificationStatusParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
