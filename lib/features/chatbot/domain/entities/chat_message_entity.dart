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
  final bool isStreaming;
  final String? summary;
  final double? streamingProgress;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.category,
    required this.timestamp,
    this.metadata,
    this.isLoading = false,
    this.isStreaming = false,
    this.summary,
    this.streamingProgress,
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
    isStreaming,
    summary,
    streamingProgress,
  ];

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageCategory? category,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isLoading,
    bool? isStreaming,
    String? summary,
    double? streamingProgress,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      summary: summary ?? this.summary,
      streamingProgress: streamingProgress ?? this.streamingProgress,
    );
  }
}
