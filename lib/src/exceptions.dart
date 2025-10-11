/// Custom exceptions for MayrConfig.
///
/// Provides clear error messages for common configuration issues.
library;

/// Base exception class for all MayrConfig errors.
abstract class MayrConfigException implements Exception {
  final String message;

  MayrConfigException(this.message);

  @override
  String toString() => 'MayrConfigException: $message';
}

/// Thrown when a configuration file is not found.
class ConfigFileNotFound extends MayrConfigException {
  final String path;

  ConfigFileNotFound(this.path)
      : super('Configuration file not found: $path');

  @override
  String toString() => 'ConfigFileNotFound: $path';
}

/// Thrown when a required configuration key is not found.
class ConfigKeyNotFound extends MayrConfigException {
  final String key;

  ConfigKeyNotFound(this.key)
      : super('Configuration key not found: $key');

  @override
  String toString() => 'ConfigKeyNotFound: $key';
}

/// Thrown when a configuration value has the wrong type.
class ConfigTypeMismatch extends MayrConfigException {
  final String key;
  final Type expectedType;
  final Type actualType;

  ConfigTypeMismatch(this.key, this.expectedType, this.actualType)
      : super(
          'Type mismatch for key "$key": expected $expectedType, got $actualType',
        );

  @override
  String toString() =>
      'ConfigTypeMismatch: $key (expected $expectedType, got $actualType)';
}

/// Thrown when configuration validation fails.
class ConfigValidationError extends MayrConfigException {
  ConfigValidationError(super.message);

  @override
  String toString() => 'ConfigValidationError: $message';
}
