import 'package:equatable/equatable.dart';

enum MessageType { user, assistant, system, error, loading }

enum MessageCategory {
  greeting,
  appInfo,
  lawInfo,
  contextual,
  outOfContext,
  error,
  help,
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final MessageCategory category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isLoading;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.category,
    required this.timestamp,
    this.metadata,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    type,
    category,
    timestamp,
    metadata,
    isLoading,
  ];

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageCategory? category,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isLoading,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
