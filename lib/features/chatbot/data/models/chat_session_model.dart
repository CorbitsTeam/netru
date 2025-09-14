import '../../domain/entities/chat_session_entity.dart';
import 'chat_message_model.dart';

class ChatSessionModel extends ChatSessionEntity {
  const ChatSessionModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.messages,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.metadata,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? [];
    final messages =
        messagesJson
            .map(
              (messageJson) => ChatMessageModel.fromJson(
                messageJson as Map<String, dynamic>,
              ),
            )
            .toList();

    return ChatSessionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'محادثة جديدة',
      messages: messages,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'messages':
          messages
              .map((message) => ChatMessageModel.fromEntity(message).toJson())
              .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory ChatSessionModel.fromEntity(ChatSessionEntity entity) {
    return ChatSessionModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      messages: entity.messages,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      metadata: entity.metadata,
    );
  }

  // Factory for creating a new session
  factory ChatSessionModel.create({
    required String id,
    required String userId,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return ChatSessionModel(
      id: id,
      userId: userId,
      title: title ?? 'محادثة ${now.day}/${now.month}/${now.year}',
      messages: const [],
      createdAt: now,
      updatedAt: now,
      isActive: true,
      metadata: metadata,
    );
  }

  // Convert to create JSON for API
  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'title': title,
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  // Convert to update JSON for API
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'is_active': isActive,
      'metadata': metadata,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
