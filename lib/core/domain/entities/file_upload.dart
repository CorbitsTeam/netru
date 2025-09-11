import 'package:equatable/equatable.dart';

class FileUpload extends Equatable {
  final String id;
  final String fileName;
  final String mimeType;
  final int size;
  final String url;
  final String bucketId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const FileUpload({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.url,
    required this.bucketId,
    required this.createdAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    fileName,
    mimeType,
    size,
    url,
    bucketId,
    createdAt,
    metadata,
  ];
}
