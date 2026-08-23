import 'dart:io';

import 'package:stay_alive/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Failure mapExceptionToFailure(Object exception) {
  if (exception is AuthException) {
    return _mapAuthException(exception);
  }

  if (exception is PostgrestException) {
    return _mapPostgrestException(exception);
  }

  if (exception is FunctionException) {
    return _mapFunctionException(exception);
  }

  if (exception is SocketException) {
    return const NetworkFailure(
      'Unable to reach server. Please check your internet connection.',
    );
  }

  return UnknownFailure(exception.toString());
}

Failure _mapAuthException(AuthException exception) {
  if (exception is AuthRetryableFetchException) {
    return NetworkFailure(exception.message);
  }

  final int? status = int.tryParse(exception.statusCode ?? '');
  if (status == 400 || status == 422) {
    return ValidationFailure(exception.message);
  }
  if (status == 403) {
    return PermissionFailure(exception.message);
  }
  if (status != null && status >= 500) {
    return NetworkFailure(exception.message);
  }
  return AuthFailure(exception.message);
}

Failure _mapPostgrestException(PostgrestException exception) {
  final String code = exception.code ?? '';
  final String message = exception.message;

  // 42501: insufficient_privilege — the RLS/grant equivalent of Appwrite 403.
  if (code == '42501') {
    return PermissionFailure(message);
  }

  // PGRST301/JWT errors surface as 401-equivalents.
  if (code == 'PGRST301' || code == 'PGRST302') {
    return AuthFailure(message);
  }

  // 22xxx: data exceptions, 23xxx: constraint violations — bad input.
  if (code.startsWith('22')) {
    return ValidationFailure(message);
  }

  return DatabaseFailure(message);
}

Failure _mapFunctionException(FunctionException exception) {
  final String message = exception.details?.toString() ??
      exception.reasonPhrase ??
      'Edge function call failed';

  if (exception.status == 401) {
    return AuthFailure(message);
  }
  if (exception.status == 403) {
    return PermissionFailure(message);
  }
  if (exception.status >= 500) {
    return NetworkFailure(message);
  }
  return UnknownFailure(message);
}
