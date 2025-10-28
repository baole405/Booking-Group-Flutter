import 'package:equatable/equatable.dart';

class ApiException extends Equatable implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.backendStatus,
    this.details,
  });

  final String message;
  final int? statusCode;
  final int? backendStatus;
  final Object? details;

  bool get isUnauthorized => statusCode == 401 || backendStatus == 401;

  @override
  List<Object?> get props => [message, statusCode, backendStatus, details];

  @override
  String toString() =>
      'ApiException(message: $message, statusCode: $statusCode, backendStatus: $backendStatus, details: $details)';
}

class MissingSessionException extends ApiException {
  const MissingSessionException()
      : super('Authentication required. Please sign in again.', statusCode: 401);
}
