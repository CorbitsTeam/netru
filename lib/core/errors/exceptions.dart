abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  const AppException(this.message, this.statusCode);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server Error',
    super.statusCode = 500,
  ]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache Error', super.statusCode = 500]);
}

class PermissionException extends AppException {
  const PermissionException([
    super.message = 'Permission Error',
    super.statusCode = 403,
  ]);
}

class PendingOrderException extends AppException {
  final String? pendingOrderId;

  const PendingOrderException({
    required String message,
    required this.pendingOrderId,
    required int statusCode,
  }) : super(message, statusCode);

  @override
  String toString() =>
      'PendingOrderException: $message${pendingOrderId != null ? ' (ID: $pendingOrderId)' : ''}';
}
