import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/create_session.dart';
import '../../domain/usecases/get_session.dart';
import '../../domain/usecases/get_user_sessions.dart';
import '../../domain/usecases/get_help_menu.dart';
import '../../domain/usecases/get_law_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final GetSessionUseCase _getSessionUseCase;
  final GetUserSessionsUseCase _getUserSessionsUseCase;
  final GetHelpMenuUseCase _getHelpMenuUseCase;
  final GetLawInfoUseCase _getLawInfoUseCase;
  final AuthRepository _authRepository;
  final Uuid _uuid;

  ChatCubit({
    required SendMessageUseCase sendMessageUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required GetSessionUseCase getSessionUseCase,
    required GetUserSessionsUseCase getUserSessionsUseCase,
    required GetHelpMenuUseCase getHelpMenuUseCase,
    required GetLawInfoUseCase getLawInfoUseCase,
    required AuthRepository authRepository,
    required Uuid uuid,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _createSessionUseCase = createSessionUseCase,
       _getSessionUseCase = getSessionUseCase,
       _getUserSessionsUseCase = getUserSessionsUseCase,
       _getHelpMenuUseCase = getHelpMenuUseCase,
       _getLawInfoUseCase = getLawInfoUseCase,
       _authRepository = authRepository,
       _uuid = uuid,
       super(const ChatInitial());

  /// Create a new chat session
  Future<void> createNewSession({String? title}) async {
    try {
      emit(const ChatLoading());

      // Get current user
      final userResult = await _authRepository.getCurrentUser();
      final user = userResult.fold((l) => null, (r) => r);

      if (user == null) {
        emit(const ChatError(message: 'يجب تسجيل الدخول أولاً'));
        return;
      }

      final result = await _createSessionUseCase(
        CreateSessionParams(userId: user.id ?? '', title: title),
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

      // Get current user
      final userResult = await _authRepository.getCurrentUser();
      final user = userResult.fold((l) => null, (r) => r);

      if (user == null) {
        emit(const ChatError(message: 'يجب تسجيل الدخول أولاً'));
        return;
      }

      final result = await _getUserSessionsUseCase(
        GetUserSessionsParams(userId: user.id ?? ''),
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
    final currentState = state;
    if (currentState is! ChatSessionLoaded) {
      emit(const ChatError(message: 'لا توجد جلسة نشطة'));
      return;
    }

    try {
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

      // Send message to chatbot
      final result = await _sendMessageUseCase(
        SendMessageParams(
          message: messageContent,
          sessionId: currentState.session.id,
        ),
      );

      result.fold(
        (failure) {
          // Add error message to session
          final errorMessage = ChatMessageModel.errorMessage(
            id: _uuid.v4(),
            error: failure.message,
          );
          final sessionWithError = sessionWithUserMessage.addMessage(
            errorMessage,
          );
          emit(ChatSessionLoaded(session: sessionWithError, isTyping: false));
        },
        (assistantMessage) {
          // Add assistant message to session
          final finalSession = sessionWithUserMessage.addMessage(
            assistantMessage,
          );
          emit(ChatSessionLoaded(session: finalSession, isTyping: false));
        },
      );
    } catch (e) {
      emit(ChatError(message: 'خطأ في إرسال الرسالة: $e'));
    }
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
