abstract class AppLogger {
  void debug(String message, {Map<String, Object?>? data});

  void info(String message, {Map<String, Object?>? data});

  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  });

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  });
}
