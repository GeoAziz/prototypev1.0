import 'dart:developer' as developer;

class Logger {
  final String tag;

  Logger(this.tag);

  void debug(String message) {
    developer.log('📝 DEBUG [$tag] $message');
  }

  void info(String message) {
    developer.log('ℹ️ INFO [$tag] $message');
  }

  void warning(String message) {
    developer.log('⚠️ WARN [$tag] $message');
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '❌ ERROR [$tag] $message',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
