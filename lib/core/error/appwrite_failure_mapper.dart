import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:stay_alive/core/error/failures.dart';

Failure mapExceptionToFailure(Object exception) {
  if (exception is AppwriteException) {
    return _mapAppwriteException(exception);
  }

  if (exception is SocketException) {
    return const NetworkFailure('Unable to reach server. Please check your internet connection.');
  }

  return UnknownFailure(exception.toString());
}

Failure _mapAppwriteException(AppwriteException exception) {
  final int? code = exception.code;
  final String message = exception.message ?? 'Unknown Appwrite error';

  if (code == null) {
    return UnknownFailure(message);
  }

  if (code == 400) {
    return ValidationFailure(message);
  }

  if (code == 401) {
    return AuthFailure(message);
  }

  if (code == 403) {
    return PermissionFailure(message);
  }

  if (code == 404 || code == 409 || code == 422) {
    return DatabaseFailure(message);
  }

  if (code >= 500) {
    return NetworkFailure(message);
  }

  return UnknownFailure(message);
}
