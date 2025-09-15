class ServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic error;

  ServiceException(this.message, {this.code, this.error});

  @override
  String toString() {
    return 'ServiceException: $message ${code != null ? '($code)' : ''}';
  }
}

class NetworkException extends ServiceException {
  NetworkException(super.message, {super.code, super.error});
}

class DataNotFoundException extends ServiceException {
  DataNotFoundException(super.message, {super.code, super.error});
}

class ValidationException extends ServiceException {
  ValidationException(super.message, {super.code, super.error});
}

class UnauthorizedException extends ServiceException {
  UnauthorizedException(super.message, {super.code, super.error});
}

class ServerException extends ServiceException {
  ServerException(super.message, {super.code, super.error});
}
