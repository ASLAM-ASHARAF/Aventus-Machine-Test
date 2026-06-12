import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;


  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('The connection timed out. Please retry.');
      case DioExceptionType.badResponse:
        final int? code = error.response?.statusCode;
        return ApiException(
          'Server responded with an error (${code ?? 'unknown'}).',
          statusCode: code,
        );
      case DioExceptionType.connectionError:
        return const ApiException('Unable to reach the server.');
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('Invalid server certificate.');
      case DioExceptionType.unknown:
        return ApiException(
          'An unexpected network error occurred: ${error.message ?? ''}',
        );
    }
  }

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}
