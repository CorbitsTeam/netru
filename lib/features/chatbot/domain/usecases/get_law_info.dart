import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class GetLawInfoUseCase implements UseCase<String, GetLawInfoParams> {
  final ChatRepository repository;

  const GetLawInfoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetLawInfoParams params) async {
    return await repository.getLawInfo(params.category);
  }
}

class GetLawInfoParams extends Equatable {
  final String category;

  const GetLawInfoParams({required this.category});

  @override
  List<Object> get props => [category];
}
