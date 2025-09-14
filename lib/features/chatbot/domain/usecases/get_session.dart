import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_session_entity.dart';
import '../repositories/chat_repository.dart';

class GetSessionUseCase
    implements UseCase<ChatSessionEntity?, GetSessionParams> {
  final ChatRepository repository;

  const GetSessionUseCase(this.repository);

  @override
  Future<Either<Failure, ChatSessionEntity?>> call(
    GetSessionParams params,
  ) async {
    return await repository.getSession(params.sessionId);
  }
}

class GetSessionParams extends Equatable {
  final String sessionId;

  const GetSessionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
