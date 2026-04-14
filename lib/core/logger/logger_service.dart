import 'dart:developer' as developer;

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
  }

  String _composeMessage(String message, Map<String, Object?>? data) {
    if (data == null || data.isEmpty) {
      return message;
    }

    return '$message | data=$data';
  }
}
