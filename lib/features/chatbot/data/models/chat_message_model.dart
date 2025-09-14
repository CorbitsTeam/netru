import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.type,
    required super.category,
    required super.timestamp,
    super.metadata,
    super.isLoading,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: _parseMessageType(json['type']),
      category: _parseMessageCategory(json['category']),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isLoading: json['isLoading'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isLoading': isLoading,
    };
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.user;
    switch (type.toString()) {
      case 'user':
        return MessageType.user;
      case 'assistant':
        return MessageType.assistant;
      case 'system':
        return MessageType.system;
      case 'error':
        return MessageType.error;
      case 'loading':
        return MessageType.loading;
      default:
        return MessageType.user;
    }
  }

  static MessageCategory _parseMessageCategory(dynamic category) {
    if (category == null) return MessageCategory.contextual;
    switch (category.toString()) {
      case 'greeting':
        return MessageCategory.greeting;
      case 'appInfo':
        return MessageCategory.appInfo;
      case 'lawInfo':
        return MessageCategory.lawInfo;
      case 'contextual':
        return MessageCategory.contextual;
      case 'outOfContext':
        return MessageCategory.outOfContext;
      case 'error':
        return MessageCategory.error;
      case 'help':
        return MessageCategory.help;
      default:
        return MessageCategory.contextual;
    }
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      type: entity.type,
      category: entity.category,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
      isLoading: entity.isLoading,
    );
  }

  // Factory for creating user messages
  factory ChatMessageModel.userMessage({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      type: MessageType.user,
      category: MessageCategory.contextual,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  // Factory for creating assistant messages
  factory ChatMessageModel.assistantMessage({
    required String id,
    required String content,
    required MessageCategory category,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      type: MessageType.assistant,
      category: category,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  // Factory for creating loading messages
  factory ChatMessageModel.loadingMessage({required String id}) {
    return ChatMessageModel(
      id: id,
      content: 'جاري الكتابة...',
      type: MessageType.loading,
      category: MessageCategory.contextual,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  // Factory for creating error messages
  factory ChatMessageModel.errorMessage({
    required String id,
    required String error,
  }) {
    return ChatMessageModel(
      id: id,
      content: 'عذراً، حدث خطأ: $error',
      type: MessageType.error,
      category: MessageCategory.error,
      timestamp: DateTime.now(),
    );
  }
}
