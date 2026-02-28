import 'package:equatable/equatable.dart';

/// Base failure for the app. UI maps these to messages.
abstract class Failure extends Equatable {
  const Failure([this.message]);
  final String? message;
  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({
    this.productName,
    this.requested,
    this.available,
    String? message,
  }) : super(message);
  final String? productName;
  final int? requested;
  final int? available;
  @override
  List<Object?> get props => [message, productName, requested, available];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message]);
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message]);
}

class EditWindowExpiredFailure extends Failure {
  const EditWindowExpiredFailure([super.message]);
}

class DuplicateInvoiceNumberFailure extends Failure {
  const DuplicateInvoiceNumberFailure([super.message]);
}
