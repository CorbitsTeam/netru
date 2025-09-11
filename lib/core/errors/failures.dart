import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}

class GenericFailure extends Failure {
  const GenericFailure(super.message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// Document/Verification failures
class DocumentScanFailure extends Failure {
  const DocumentScanFailure(super.message);
}

class FileUploadFailure extends Failure {
  const FileUploadFailure(super.message);
}