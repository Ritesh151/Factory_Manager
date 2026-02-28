/// Base exception for data layer. Repositories convert to [Failure] for domain.
class AppException implements Exception {
  AppException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'AppException';
}

class CacheException extends AppException {
  CacheException([super.message]);
}

class ServerException extends AppException {
  ServerException([super.message]);
}

class ValidationException extends AppException {
  ValidationException([super.message]);
}

class NotFoundException extends AppException {
  NotFoundException([super.message]);
}

class InsufficientStockException extends AppException {
  InsufficientStockException([super.message]);
}

class EditWindowExpiredException extends AppException {
  EditWindowExpiredException([super.message]);
}

class DuplicateInvoiceNumberException extends AppException {
  DuplicateInvoiceNumberException([super.message]);
}
