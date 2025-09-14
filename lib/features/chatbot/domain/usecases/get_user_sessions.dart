import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_session_entity.dart';
import '../repositories/chat_repository.dart';

class GetUserSessionsUseCase
    implements UseCase<List<ChatSessionEntity>, GetUserSessionsParams> {
  final ChatRepository repository;

  const GetUserSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatSessionEntity>>> call(
    GetUserSessionsParams params,
  ) async {
    return await repository.getUserSessions(params.userId);
  }
}

class GetUserSessionsParams extends Equatable {
  final String userId;

  const GetUserSessionsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
