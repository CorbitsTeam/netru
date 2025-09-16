import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message_entity.dart';
import '../entities/chat_session_entity.dart';

abstract class ChatRepository {
  /// Send a message to the chatbot and get response
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String message,
    required String sessionId,
    Map<String, dynamic>? context,
  });

  /// Create a new chat session
  Future<Either<Failure, ChatSessionEntity>> createSession({
    required String userId,
    String? title,
    Map<String, dynamic>? metadata,
  });

  /// Get a specific chat session
  Future<Either<Failure, ChatSessionEntity?>> getSession(String sessionId);

  /// Get all chat sessions for a user
  Future<Either<Failure, List<ChatSessionEntity>>> getUserSessions(
    String userId,
  );

  /// Update a chat session
  Future<Either<Failure, ChatSessionEntity>> updateSession(
    ChatSessionEntity session,
  );

  /// Delete a chat session
  Future<Either<Failure, bool>> deleteSession(String sessionId);

  /// Get chat history for a session
  Future<Either<Failure, List<ChatMessageEntity>>> getSessionMessages(
    String sessionId,
  );

  /// Save a message to storage
  Future<Either<Failure, ChatMessageEntity>> saveMessage(
    ChatMessageEntity message,
  );

  /// Get help menu/topics
  Future<Either<Failure, String>> getHelpMenu();

  /// Get law information by category
  Future<Either<Failure, String>> getLawInfo(String category);

  /// Check if context is allowed
  Future<Either<Failure, bool>> isContextAllowed(String message);
}
