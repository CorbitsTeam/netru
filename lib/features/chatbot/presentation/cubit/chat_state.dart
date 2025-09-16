import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatSessionLoaded extends ChatState {
  final ChatSessionEntity session;
  final bool isTyping;

  const ChatSessionLoaded({required this.session, this.isTyping = false});

  @override
  List<Object?> get props => [session, isTyping];

  ChatSessionLoaded copyWith({ChatSessionEntity? session, bool? isTyping}) {
    return ChatSessionLoaded(
      session: session ?? this.session,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatSessionsLoaded extends ChatState {
  final List<ChatSessionEntity> sessions;

  const ChatSessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatMessageSending extends ChatState {
  final ChatSessionEntity session;
  final ChatMessageEntity pendingMessage;

  const ChatMessageSending({
    required this.session,
    required this.pendingMessage,
  });

  @override
  List<Object?> get props => [session, pendingMessage];
}

class ChatHelpDisplayed extends ChatState {
  final String helpContent;

  const ChatHelpDisplayed({required this.helpContent});

  @override
  List<Object?> get props => [helpContent];
}
