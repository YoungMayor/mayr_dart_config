/// String extension for convenient configuration access.
///
/// Provides syntactic sugar for accessing configuration values.
library;

import 'core.dart';

/// Extension on String to provide convenient config access.
///
/// This adds a `config` property and `config<T>()` method to all strings,
/// allowing for clean, readable configuration access.
///
/// Example:
/// ```dart
/// final baseUrl = 'api.baseUrl'.config;
/// final timeout = 'api.timeout'.config<int>();
/// ```
extension MayrConfigStringExt on String {
  /// Get a configuration value using this string as the key.
  ///
  /// Returns dynamic type. Use [config<T>()] for type-safe access.
  ///
  /// Example:
  /// ```dart
  /// final name = 'app.name'.config;
  /// final url = 'api.baseUrl'.config;
  /// ```
  dynamic get config => MayrConfig.get(this);

  /// Get a type-safe configuration value using this string as the key.
  ///
  /// Throws [ConfigKeyNotFound] if key doesn't exist.
  /// Throws [ConfigTypeMismatch] if value is not of type T.
  ///
  /// Example:
  /// ```dart
  /// final timeout = 'api.timeout'.config<int>();
  /// final debug = 'app.debug'.config<bool>();
  /// ```
  T configValue<T>() => MayrConfig.getValue<T>(this);
}
