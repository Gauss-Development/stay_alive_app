import 'dart:developer' as developer;

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stay_alive/core/logger/app_logger.dart';

class LoggerService implements AppLogger {
  const LoggerService();

  @override
  void debug(String message, {Map<String, Object?>? data}) {
    developer.log(
      _composeMessage(message, data),
      name: 'DailyDozen.debug',
      level: 500,
    );
  }

  @override
  void info(String message, {Map<String, Object?>? data}) {
    developer.log(
      _composeMessage(message, data),
      name: 'DailyDozen.info',
      level: 800,
    );
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    developer.log(
      _composeMessage(message, data),
      name: 'DailyDozen.warning',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
    Sentry.addBreadcrumb(
      Breadcrumb(
        level: SentryLevel.warning,
        message: message,
        data: data?.map<String, Object?>(
          (String key, Object? value) => MapEntry<String, Object?>(key, value),
        ),
      ),
    );
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    developer.log(
      _composeMessage(message, data),
      name: 'DailyDozen.error',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setContexts('message', message);
          if (data != null) {
            scope.setContexts('data', data);
          }
        },
      );
    } else {
      Sentry.captureMessage(
        message,
        level: SentryLevel.error,
        withScope: (Scope scope) {
          if (data != null) {
            scope.setContexts('data', data);
          }
        },
      );
    }
  }

  String _composeMessage(String message, Map<String, Object?>? data) {
    if (data == null || data.isEmpty) {
      return message;
    }

    return '$message | data=$data';
  }
}
