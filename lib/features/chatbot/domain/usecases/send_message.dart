import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase
    implements UseCase<ChatMessageEntity, SendMessageParams> {
  final ChatRepository repository;

  const SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessageEntity>> call(
    SendMessageParams params,
  ) async {
    return await repository.sendMessage(
      message: params.message,
      sessionId: params.sessionId,
      context: params.context,
    );
  }
}

class SendMessageParams extends Equatable {
  final String message;
  final String sessionId;
  final Map<String, dynamic>? context;

  const SendMessageParams({
    required this.message,
    required this.sessionId,
    this.context,
  });

  @override
  List<Object?> get props => [message, sessionId, context];
}
