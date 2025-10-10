/// Public API for loading and accessing configuration values.
///
/// This class provides the main interface for users to interact with
/// the configuration system.
library;

import 'core.dart';

/// Public-facing API for reading values and loading config files.
///
/// This class wraps around the core singleton and provides a clean,
/// simple interface for configuration management.
class MayrConfig {
  static final MayrConfigCore _core = MayrConfigCore();

  /// Load configuration from YAML and .env files.
  ///
  /// This is a convenience method that loads both the YAML configuration
  /// and environment variables in one call.
  ///
  /// Example:
  /// ```dart
  /// await MayrConfig.load(
  ///   yamlPath: 'config.yaml',
  ///   envPath: '.env',
  /// );
  /// ```
  static Future<void> load({
    String yamlPath = 'config.yaml',
    String envPath = '.env',
  }) async {
    await _core.loadEnv(envPath);
    await _core.loadFromYaml(yamlPath);
  }

  /// Load configuration from a YAML file.
  ///
  /// This method also automatically loads the .env file if present.
  ///
  /// Example:
  /// ```dart
  /// await MayrConfig.loadFromYaml('config.yaml');
  /// ```
  static Future<void> loadFromYaml(
    String path, [
    String envPath = '.env',
  ]) async {
    await _core.loadEnv(envPath);
    await _core.loadFromYaml(path);
  }

  /// Get a configuration value by key using dot notation.
  ///
  /// Returns [defaultValue] if the key is not found.
  ///
  /// Example:
  /// ```dart
  /// final appName = MayrConfig.get('app.name', 'DefaultApp');
  /// final timeout = MayrConfig.get('api.timeout');
  /// ```
  static dynamic get(String key, [dynamic defaultValue]) {
    return _core.get(key, defaultValue);
  }

  /// Check if a configuration key exists.
  ///
  /// Example:
  /// ```dart
  /// if (MayrConfig.has('app.debug')) {
  ///   print('Debug mode is configured');
  /// }
  /// ```
  static bool has(String key) {
    return _core.has(key);
  }

  /// Get all configuration keys.
  ///
  /// Returns an iterable of all available configuration keys.
  ///
  /// Example:
  /// ```dart
  /// for (var key in MayrConfig.keys()) {
  ///   print('$key: ${MayrConfig.get(key)}');
  /// }
  /// ```
  static Iterable<String> keys() {
    return _core.keys();
  }

  /// Reload configuration from the last loaded files.
  ///
  /// This is useful when you need to refresh configuration at runtime.
  ///
  /// Example:
  /// ```dart
  /// await MayrConfig.reload();
  /// ```
  static Future<void> reload() async {
    await _core.reload();
  }

  /// Clear all configuration values.
  ///
  /// This is primarily useful for testing.
  static void clear() {
    _core.clear();
  }
}
