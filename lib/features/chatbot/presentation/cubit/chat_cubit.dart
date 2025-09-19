import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/user_data_helper.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/usecases/create_session.dart';
import '../../domain/usecases/get_help_menu.dart';
import '../../domain/usecases/get_law_info.dart';
import '../../domain/usecases/get_session.dart';
import '../../domain/usecases/get_user_sessions.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final GetSessionUseCase _getSessionUseCase;
  final GetUserSessionsUseCase _getUserSessionsUseCase;
  final GetHelpMenuUseCase _getHelpMenuUseCase;
  final GetLawInfoUseCase _getLawInfoUseCase;
  final Uuid _uuid;

  ChatCubit({
    required SendMessageUseCase sendMessageUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required GetSessionUseCase getSessionUseCase,
    required GetUserSessionsUseCase getUserSessionsUseCase,
    required GetHelpMenuUseCase getHelpMenuUseCase,
    required GetLawInfoUseCase getLawInfoUseCase,
    required Uuid uuid,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _createSessionUseCase = createSessionUseCase,
       _getSessionUseCase = getSessionUseCase,
       _getUserSessionsUseCase = getUserSessionsUseCase,
       _getHelpMenuUseCase = getHelpMenuUseCase,
       _getLawInfoUseCase = getLawInfoUseCase,
       _uuid = uuid,
       super(const ChatInitial());

  /// Create a new chat session
  Future<void> createNewSession({String? title}) async {
    try {
      emit(const ChatLoading());

      // Get current user from local helper (faster null check)
      final user = UserDataHelper().getCurrentUser();

      if (user == null) {
        // Create a session for non-logged user with a temporary ID
        final tempUserId = _uuid.v4();
        final result = await _createSessionUseCase(
          CreateSessionParams(userId: tempUserId, title: title ?? 'محادثة ضيف'),
        );

        result.fold(
          (failure) => emit(ChatError(message: failure.message)),
          (session) => emit(ChatSessionLoaded(session: session)),
        );
        return;
      }

      final result = await _createSessionUseCase(
        CreateSessionParams(userId: user.id, title: title),
      );

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (session) => emit(ChatSessionLoaded(session: session)),
      );
    } catch (e) {
      emit(ChatError(message: 'خطأ في إنشاء جلسة المحادثة: $e'));
    }
  }

  /// Load an existing session
  Future<void> loadSession(String sessionId) async {
    try {
      emit(const ChatLoading());

      final result = await _getSessionUseCase(
        GetSessionParams(sessionId: sessionId),
      );

      result.fold((failure) => emit(ChatError(message: failure.message)), (
        session,
      ) {
        if (session != null) {
          emit(ChatSessionLoaded(session: session));
        } else {
          emit(const ChatError(message: 'الجلسة غير موجودة'));
        }
      });
    } catch (e) {
      emit(ChatError(message: 'خطأ في تحميل الجلسة: $e'));
    }
  }

  /// Load all user sessions
  Future<void> loadUserSessions() async {
    try {
      emit(const ChatLoading());

      // Get current user from local helper (faster null check)
      final user = UserDataHelper().getCurrentUser();

      if (user == null) {
        // For non-logged users, show empty sessions list but allow creating new chats
        emit(const ChatSessionsLoaded(sessions: []));
        return;
      }

      final result = await _getUserSessionsUseCase(
        GetUserSessionsParams(userId: user.id),
      );

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (sessions) => emit(ChatSessionsLoaded(sessions: sessions)),
      );
    } catch (e) {
      emit(ChatError(message: 'خطأ في تحميل الجلسات: $e'));
    }
  }

  /// Send a message in the current session
  Future<void> sendMessage(String messageContent) async {
    log('🚀 إرسال رسالة من ChatCubit: $messageContent');

    final currentState = state;
    if (currentState is! ChatSessionLoaded) {
      log('❌ لا توجد جلسة نشطة');
      emit(const ChatError(message: 'لا توجد جلسة نشطة'));
      return;
    }

    try {
      log('📝 إنشاء رسالة المستخدم...');
      // Create user message
      final userMessage = ChatMessageModel.userMessage(
        id: _uuid.v4(),
        content: messageContent,
        metadata: {'sessionId': currentState.session.id},
      );

      // Add user message to session and show immediately
      final sessionWithUserMessage = currentState.session.addMessage(
        userMessage,
      );
      emit(ChatSessionLoaded(session: sessionWithUserMessage, isTyping: true));
      log('✅ رسالة المستخدم تمت إضافتها إلى الجلسة');

      // Create a streaming assistant message with empty content
      final streamingMessage = ChatMessageModel.streamingMessage(
        id: _uuid.v4(),
        content: '',
        category: MessageCategory.contextual,
      );

      // Add streaming message to session
      final sessionWithStreaming = sessionWithUserMessage.addMessage(
        streamingMessage,
      );
      emit(ChatSessionLoaded(session: sessionWithStreaming, isTyping: true));
      log('🎬 رسالة الأنيميشن تمت إضافتها');

      log('📡 إرسال الرسالة إلى SendMessageUseCase...');
      // Send message to chatbot
      final result = await _sendMessageUseCase(
        SendMessageParams(
          message: messageContent,
          sessionId: currentState.session.id,
        ),
      );

      log('📥 استلام النتيجة من SendMessageUseCase');
      result.fold(
        (failure) {
          log('❌ فشل إرسال الرسالة: ${failure.message}');
          // Remove streaming message and add error message
          final sessionWithoutStreaming = sessionWithUserMessage;
          final errorMessage = ChatMessageModel.errorMessage(
            id: _uuid.v4(),
            error: failure.message,
          );
          final sessionWithError = sessionWithoutStreaming.addMessage(
            errorMessage,
          );
          emit(ChatSessionLoaded(session: sessionWithError, isTyping: false));
        },
        (assistantMessage) {
          log(
            '✅ تم الحصول على رد المساعد بنجاح: ${assistantMessage.content.substring(0, 50)}...',
          );
          // Simulate streaming effect by updating the message content gradually
          _simulateStreamingResponse(
            sessionWithUserMessage,
            streamingMessage.id,
            assistantMessage.content,
            assistantMessage.category,
          );
        },
      );
    } catch (e) {
      log('💥 خطأ في sendMessage: $e');
      emit(ChatError(message: 'خطأ في إرسال الرسالة: $e'));
    }
  }

  /// Simulate streaming response effect
  void _simulateStreamingResponse(
    ChatSessionEntity session,
    String messageId,
    String fullContent,
    MessageCategory category,
  ) async {
    if (fullContent.isEmpty) {
      log('⚠️ المحتوى فارغ، لن يتم تشغيل الأنيميشن');
      return;
    }

    try {
      log('🎬 بدء تشغيل أنيميشن الكتابة للرسالة: $messageId');

      // Clean the content to prevent UTF-16 issues
      final cleanContent = _sanitizeText(fullContent);

      // Generate summary for long content (especially law-related)
      String? summary;
      if (cleanContent.length > 500 &&
          (category == MessageCategory.lawInfo ||
              cleanContent.contains('قانون') ||
              cleanContent.contains('العقوبة') ||
              cleanContent.contains('المادة'))) {
        summary = _generateSummary(cleanContent);
      }

      // Simulate character-by-character streaming with optimized performance
      const charsPerUpdate = 8; // Smaller chunks for smoother animation
      const updateDelay = Duration(milliseconds: 30); // Faster updates
      const maxUpdates = 100; // Increased limit for longer content

      int currentIndex = 0;
      int updateCount = 0;

      while (currentIndex < cleanContent.length && updateCount < maxUpdates) {
        // Calculate next chunk
        final endIndex = (currentIndex + charsPerUpdate).clamp(
          0,
          cleanContent.length,
        );
        final currentContent = cleanContent.substring(0, endIndex);

        // Update the streaming message
        final updatedMessage = ChatMessageModel.streamingMessage(
          id: messageId,
          content: currentContent,
          category: category,
          summary: summary,
          progress: endIndex / cleanContent.length,
        );

        // Update session with the new content - only if state hasn't changed
        final currentState = state;
        if (currentState is ChatSessionLoaded) {
          final updatedSession = currentState.session.updateMessage(
            messageId,
            updatedMessage,
          );
          emit(ChatSessionLoaded(session: updatedSession, isTyping: true));
        }

        currentIndex = endIndex;
        updateCount++;

        // Add delay for streaming effect
        if (currentIndex < cleanContent.length && updateCount < maxUpdates) {
          await Future.delayed(updateDelay);
        }
      }

      // Final update - mark as complete streaming
      final finalMessage = ChatMessageModel(
        id: messageId,
        content: cleanContent,
        type: MessageType.assistant,
        category: category,
        timestamp: DateTime.now(),
        isStreaming: false,
        summary: summary,
      );

      final currentState = state;
      if (currentState is ChatSessionLoaded) {
        final finalSession = currentState.session.updateMessage(
          messageId,
          finalMessage,
        );
        emit(ChatSessionLoaded(session: finalSession, isTyping: false));
      }

      log('✅ انتهت أنيميشن الكتابة للرسالة: $messageId');
    } catch (e) {
      log('💥 خطأ في streaming: $e');
      // Fallback to immediate display on error
      final finalMessage = ChatMessageModel.assistantMessage(
        id: messageId,
        content: _sanitizeText(fullContent),
        category: category,
      );
      final currentState = state;
      if (currentState is ChatSessionLoaded) {
        final finalSession = currentState.session.updateMessage(
          messageId,
          finalMessage,
        );
        emit(ChatSessionLoaded(session: finalSession, isTyping: false));
      }
    }
  }

  /// Sanitize text to prevent UTF-16 issues
  String _sanitizeText(String text) {
    try {
      return text.runes
          .where((rune) => rune != 0xFFFD && rune <= 0x10FFFF)
          .map((rune) => String.fromCharCode(rune))
          .join('')
          .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '')
          .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '')
          .trim();
    } catch (e) {
      log('⚠️ خطأ في تنظيف النص: $e');
      return text.replaceAll(
        RegExp(r'[^\x20-\x7E\u0600-\u06FF\u0750-\u077F]'),
        '',
      );
    }
  }

  /// Generate summary for long content
  String _generateSummary(String content) {
    // Extract key points from legal content
    if (content.contains('العقوبة') ||
        content.contains('الحبس') ||
        content.contains('الغرامة')) {
      // Law penalty summary
      final penalties = <String>[];
      if (content.contains('الحبس')) {
        final prisonMatch = RegExp(
          r'الحبس.*?(?:سنة|شهر|يوم)',
        ).firstMatch(content);
        if (prisonMatch != null) {
          penalties.add('العقوبة: ${prisonMatch.group(0)}');
        }
      }
      if (content.contains('الغرامة')) {
        final fineMatch = RegExp(r'غرامة.*?جنيه').firstMatch(content);
        if (fineMatch != null) {
          penalties.add(fineMatch.group(0) ?? '');
        }
      }

      if (penalties.isNotEmpty) {
        return penalties.join(' • ');
      }
    }

    // General summary for other content
    final sentences = content.split('.');
    if (sentences.length > 2) {
      return '${sentences.first.trim()}. ${sentences[1].trim()}.';
    }

    // Fallback to first 100 characters
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  /// Show help menu
  Future<void> showHelp() async {
    try {
      final result = await _getHelpMenuUseCase(const NoParams());

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (helpContent) => emit(ChatHelpDisplayed(helpContent: helpContent)),
      );
    } catch (e) {
      emit(ChatError(message: 'خطأ في جلب المساعدة: $e'));
    }
  }

  /// Get law information
  Future<void> getLawInfo(String category) async {
    final currentState = state;
    if (currentState is! ChatSessionLoaded) {
      emit(const ChatError(message: 'لا توجد جلسة نشطة'));
      return;
    }

    try {
      emit(currentState.copyWith(isTyping: true));

      final result = await _getLawInfoUseCase(
        GetLawInfoParams(category: category),
      );

      result.fold(
        (failure) {
          final errorMessage = ChatMessageModel.errorMessage(
            id: _uuid.v4(),
            error: failure.message,
          );
          final sessionWithError = currentState.session.addMessage(
            errorMessage,
          );
          emit(ChatSessionLoaded(session: sessionWithError, isTyping: false));
        },
        (lawInfo) {
          final lawMessage = ChatMessageModel.assistantMessage(
            id: _uuid.v4(),
            content: lawInfo,
            category: MessageCategory.lawInfo,
          );
          final sessionWithLawInfo = currentState.session.addMessage(
            lawMessage,
          );
          emit(ChatSessionLoaded(session: sessionWithLawInfo, isTyping: false));
        },
      );
    } catch (e) {
      emit(ChatError(message: 'خطأ في جلب معلومات القانون: $e'));
    }
  }

  /// Add a quick response message
  void addQuickResponse(String response) {
    final currentState = state;
    if (currentState is ChatSessionLoaded) {
      final quickMessage = ChatMessageModel.assistantMessage(
        id: _uuid.v4(),
        content: response,
        category: MessageCategory.help,
      );
      final updatedSession = currentState.session.addMessage(quickMessage);
      emit(ChatSessionLoaded(session: updatedSession));
    }
  }

  /// Clear current session and go back to initial state
  void clearCurrentSession() {
    emit(const ChatInitial());
  }

  /// Set typing indicator
  void setTyping(bool isTyping) {
    final currentState = state;
    if (currentState is ChatSessionLoaded) {
      emit(currentState.copyWith(isTyping: isTyping));
    }
  }
}
