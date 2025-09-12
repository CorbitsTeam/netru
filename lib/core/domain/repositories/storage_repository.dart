import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../errors/failures.dart';
import '../entities/file_upload.dart';

abstract class StorageRepository {
  Future<Either<Failure, FileUpload>> uploadFile(
    String bucket,
    String path,
    Uint8List fileBytes, {
    String? mimeType,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, FileUpload>> uploadFromPath(
    String bucket,
    String path,
    String filePath, {
    String? mimeType,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, String>> getPublicUrl(String bucket, String path);

  Future<Either<Failure, String>> getSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
  });

  Future<Either<Failure, Uint8List>> downloadFile(String bucket, String path);

  Future<Either<Failure, void>> deleteFile(String bucket, String path);

  Future<Either<Failure, List<FileUpload>>> listFiles(
    String bucket, {
    String? prefix,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, void>> createBucket(String bucketName);

  Future<Either<Failure, void>> deleteBucket(String bucketName);
}
