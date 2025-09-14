import 'package:equatable/equatable.dart';
import 'chat_message_entity.dart';

class ChatSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final List<ChatMessageEntity> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const ChatSessionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    messages,
    createdAt,
    updatedAt,
    isActive,
    metadata,
  ];

  ChatSessionEntity copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessageEntity>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  ChatSessionEntity addMessage(ChatMessageEntity message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  ChatSessionEntity updateMessage(
    String messageId,
    ChatMessageEntity updatedMessage,
  ) {
    final updatedMessages =
        messages.map((msg) {
          return msg.id == messageId ? updatedMessage : msg;
        }).toList();

    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  ChatSessionEntity removeMessage(String messageId) {
    final filteredMessages =
        messages.where((msg) => msg.id != messageId).toList();

    return copyWith(messages: filteredMessages, updatedAt: DateTime.now());
  }
}
