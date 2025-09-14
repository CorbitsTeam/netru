import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_session_entity.dart';
import '../repositories/chat_repository.dart';

class CreateSessionUseCase
    implements UseCase<ChatSessionEntity, CreateSessionParams> {
  final ChatRepository repository;

  const CreateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, ChatSessionEntity>> call(
    CreateSessionParams params,
  ) async {
    return await repository.createSession(
      userId: params.userId,
      title: params.title,
      metadata: params.metadata,
    );
  }
}

class CreateSessionParams extends Equatable {
  final String userId;
  final String? title;
  final Map<String, dynamic>? metadata;

  const CreateSessionParams({required this.userId, this.title, this.metadata});

  @override
  List<Object?> get props => [userId, title, metadata];
}
