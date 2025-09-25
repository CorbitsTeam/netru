import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckUserExistsUseCase implements UseCase<bool, CheckUserExistsParams> {
  final AuthRepository repository;

  CheckUserExistsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckUserExistsParams params) async {
    return await repository.checkUserExists(params.identifier);
  }
}

class CheckUserExistsParams extends Equatable {
  final String identifier;

  const CheckUserExistsParams({required this.identifier});

  @override
  List<Object> get props => [identifier];
}
