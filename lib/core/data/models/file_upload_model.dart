import '../../domain/entities/file_upload.dart';

class FileUploadModel extends FileUpload {
  const FileUploadModel({
    required super.id,
    required super.fileName,
    required super.mimeType,
    required super.size,
    required super.url,
    required super.bucketId,
    required super.createdAt,
    super.metadata,
  });

  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
      id: json['id'] ?? '',
      fileName: json['name'] ?? '',
      mimeType: json['mime_type'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      url: json['url'] ?? '',
      bucketId: json['bucket_id'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fileName,
      'mime_type': mimeType,
      'size': size,
      'url': url,
      'bucket_id': bucketId,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory FileUploadModel.fromEntity(FileUpload file) {
    return FileUploadModel(
      id: file.id,
      fileName: file.fileName,
      mimeType: file.mimeType,
      size: file.size,
      url: file.url,
      bucketId: file.bucketId,
      createdAt: file.createdAt,
      metadata: file.metadata,
    );
  }
}
