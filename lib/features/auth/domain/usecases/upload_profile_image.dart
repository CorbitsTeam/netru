import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UploadProfileImageUseCase
    implements UseCase<String, UploadProfileImageParams> {
  final AuthRepository repository;

  UploadProfileImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfileImageParams params) async {
    return await repository.uploadDocument(params.imageFile, params.fileName);
  }
}

class UploadProfileImageParams extends Equatable {
  final File imageFile;
  final String fileName;

  const UploadProfileImageParams({
    required this.imageFile,
    required this.fileName,
  });

  @override
  List<Object> get props => [imageFile, fileName];
}
