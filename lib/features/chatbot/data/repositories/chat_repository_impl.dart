import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chatbot_remote_data_source.dart';
import '../datasources/chatbot_local_data_source.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatbotRemoteDataSource remoteDataSource;
  final ChatbotLocalDataSource localDataSource;
  final Uuid uuid;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String message,
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    try {
      // First check if message context is allowed
      final isAllowed = await remoteDataSource.isContextAllowed(message);
      if (!isAllowed) {
        final outOfContextMessage = ChatMessageModel.assistantMessage(
          id: uuid.v4(),
          content:
              '''عذراً، أنا مساعد ذكي مختص بتطبيق نترو والقوانين المصرية ذات الصلة بالأمان والبلاغات.

يمكنني مساعدتك في:
📱 معلومات عن تطبيق نترو
⚖️ القوانين المصرية (الجنائية، المرور، حماية البيانات، إلخ)
🚨 أنواع البلاغات والحوادث
🔒 الأمان والخصوصية

يرجى طرح سؤال متعلق بهذه المواضيع.''',
          category: MessageCategory.outOfContext,
        );

        // Save the out-of-context response locally
        await localDataSource.saveMessage(sessionId, outOfContextMessage);
        return Right(outOfContextMessage);
      }

      // Send message to remote API
      final response = await remoteDataSource.sendMessage(
        message: message,
        sessionId: sessionId,
        context: context,
      );

      // Save response locally
      await localDataSource.saveMessage(sessionId, response);

      return Right(response);
    } catch (e) {
      return Left(ServerFailure('خطأ في إرسال الرسالة: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSessionEntity>> createSession({
    required String userId,
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = uuid.v4();
      final now = DateTime.now();

      final session = ChatSessionModel.create(
        id: sessionId,
        userId: userId,
        title: title ?? 'محادثة ${now.day}/${now.month}/${now.year}',
        metadata: metadata,
      );

      // Save session locally
      await localDataSource.saveSession(session);

      // Add welcome message
      final welcomeMessage = ChatMessageModel.assistantMessage(
        id: uuid.v4(),
        content: '''مرحباً! أنا المساعد الذكي لتطبيق نترو 🚨

تطبيق نترو هو أول تطبيق مصري متطور للبلاغات الأمنية، مصمم خصيصاً للمواطنين المصريين.

يمكنني مساعدتك في:
📱 معلومات عن تطبيق نترو ومميزاته
⚖️ القوانين المصرية ذات الصلة بالبلاغات والأمان
🚨 أنواع البلاغات المختلفة وكيفية التعامل معها
🔒 الأمان والخصوصية في التطبيق
🗺️ الخريطة الحرارية والمساعد الذكي سوبيك

ما الذي تريد معرفته؟''',
        category: MessageCategory.greeting,
      );

      await localDataSource.saveMessage(sessionId, welcomeMessage);

      // Update session with the welcome message
      final updatedSession = session.addMessage(welcomeMessage);
      final updatedSessionModel = ChatSessionModel.fromEntity(updatedSession);
      await localDataSource.saveSession(updatedSessionModel);

      return Right(updatedSession);
    } catch (e) {
      return Left(CacheFailure('خطأ في إنشاء جلسة المحادثة: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSessionEntity?>> getSession(
    String sessionId,
  ) async {
    try {
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return const Right(null);
      }

      // Load messages for the session
      final messages = await localDataSource.getSessionMessages(sessionId);
      final sessionWithMessages = session.copyWith(messages: messages);

      return Right(sessionWithMessages);
    } catch (e) {
      return Left(CacheFailure('خطأ في جلب الجلسة: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatSessionEntity>>> getUserSessions(
    String userId,
  ) async {
    try {
      final sessions = await localDataSource.getUserSessions(userId);

      // Load messages for each session
      final sessionsWithMessages = <ChatSessionEntity>[];
      for (final session in sessions) {
        final messages = await localDataSource.getSessionMessages(session.id);
        sessionsWithMessages.add(session.copyWith(messages: messages));
      }

      return Right(sessionsWithMessages);
    } catch (e) {
      return Left(CacheFailure('خطأ في جلب جلسات المستخدم: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSessionEntity>> updateSession(
    ChatSessionEntity session,
  ) async {
    try {
      final sessionModel = ChatSessionModel.fromEntity(session);
      await localDataSource.saveSession(sessionModel);
      return Right(session);
    } catch (e) {
      return Left(CacheFailure('خطأ في تحديث الجلسة: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSession(String sessionId) async {
    try {
      await localDataSource.deleteSession(sessionId);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('خطأ في حذف الجلسة: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getSessionMessages(
    String sessionId,
  ) async {
    try {
      final messages = await localDataSource.getSessionMessages(sessionId);
      return Right(messages.cast<ChatMessageEntity>());
    } catch (e) {
      return Left(CacheFailure('خطأ في جلب رسائل الجلسة: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> saveMessage(
    ChatMessageEntity message,
  ) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      final sessionId = message.metadata?['sessionId'] ?? '';

      if (sessionId.isEmpty) {
        return const Left(InvalidInputFailure('معرف الجلسة مطلوب'));
      }

      await localDataSource.saveMessage(sessionId, messageModel);
      return Right(message);
    } catch (e) {
      return Left(CacheFailure('خطأ في حفظ الرسالة: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getHelpMenu() async {
    try {
      final helpContent = await remoteDataSource.getHelpMenu();
      return Right(helpContent);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب قائمة المساعدة: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getLawInfo(String category) async {
    try {
      final lawInfo = await remoteDataSource.getLawInfo(category);
      return Right(lawInfo);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب معلومات القانون: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isContextAllowed(String message) async {
    try {
      final isAllowed = await remoteDataSource.isContextAllowed(message);
      return Right(isAllowed);
    } catch (e) {
      return Left(ServerFailure('خطأ في التحقق من السياق: $e'));
    }
  }
}
