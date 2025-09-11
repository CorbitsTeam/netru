import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List<Object> properties = const <Object>[]]);
}

// General failures
class ServerFailure extends Failure {
  final String message;
  
  const ServerFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  
  const CacheFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;
  
  const NetworkFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class InvalidInputFailure extends Failure {
  final String message;
  
  const InvalidInputFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class GenericFailure extends Failure {
  final String message;
  
  const GenericFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Auth failures
class AuthFailure extends Failure {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Permission failures
class PermissionFailure extends Failure {
  final String message;
  
  const PermissionFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Document/Verification failures
class DocumentScanFailure extends Failure {
  final String message;
  
  const DocumentScanFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class FileUploadFailure extends Failure {
  final String message;
  
  const FileUploadFailure(this.message);
  
  @override
  List<Object> get props => [message];
}