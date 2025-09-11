import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/errors/failures.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import '../entities/identity_document.dart';
import '../repositories/verification_repository.dart';

class GetUserDocumentsUseCase
    implements UseCase<List<IdentityDocument>, GetUserDocumentsParams> {
  final VerificationRepository repository;

  GetUserDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<IdentityDocument>>> call(
    GetUserDocumentsParams params,
  ) async {
    return await repository.getUserDocuments(params.userId);
  }
}

class GetUserDocumentsParams extends Equatable {
  final String userId;

  const GetUserDocumentsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
