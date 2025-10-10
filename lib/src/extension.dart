/// String extension for convenient configuration access.
///
/// Provides syntactic sugar for accessing configuration values.
library;

import 'loader.dart';

/// Extension on String to provide convenient config access.
///
/// This adds a `mayrConfig()` method to all strings, allowing for
/// clean, readable configuration access.
///
/// Example:
/// ```dart
/// final baseUrl = 'api.baseUrl'.mayrConfig();
/// final timeout = 'api.timeout'.mayrConfig(5000);
/// ```
extension MayrConfigStringExt on String {
  /// Get a configuration value using this string as the key.
  ///
  /// This is a convenience method equivalent to `MayrConfig.get(this, defaultValue)`.
  ///
  /// Example:
  /// ```dart
  /// 'app.name'.mayrConfig('MyApp');
  /// 'api.baseUrl'.mayrConfig();
  /// ```
  dynamic mayrConfig([dynamic defaultValue]) =>
      MayrConfig.get(this, defaultValue);
}
