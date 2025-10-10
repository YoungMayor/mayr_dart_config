/// Lightweight .env file loader and interpolator.
///
/// This class provides functionality to load environment variables from
/// a .env file and make them accessible throughout the application.
library;

import 'dart:io';

/// Tiny helper for loading .env files.
class MayrEnv {
  /// Storage for environment variables loaded from .env file.
  static final Map<String, String> _values = {};

  /// Load environment variables from a .env file.
  ///
  /// The file should contain key=value pairs, one per line.
  /// Lines starting with # are treated as comments.
  /// Empty lines are ignored.
  ///
  /// Example .env file:
  /// ```
  /// API_URL=https://api.example.com
  /// DB_PASSWORD=secret
  /// # This is a comment
  /// ```
  static Future<void> load([String path = '.env']) async {
    final file = File(path);

    if (!await file.exists()) {
      // .env file is optional, so we don't throw an error
      return;
    }

    final lines = await file.readAsLines();

    for (var line in lines) {
      line = line.trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      // Parse key=value pairs
      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) {
        continue;
      }

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      // Remove quotes if present
      final unquotedValue = _removeQuotes(value);

      _values[key] = unquotedValue;
    }
  }

  /// Get an environment variable value by key.
  ///
  /// Returns null if the key is not found.
  static String? get(String key) {
    return _values[key];
  }

  /// Remove surrounding quotes from a value.
  static String _removeQuotes(String value) {
    if (value.length >= 2) {
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        return value.substring(1, value.length - 1);
      }
    }
    return value;
  }

  /// Clear all loaded environment variables.
  static void clear() {
    _values.clear();
  }

  /// Get all loaded environment variables.
  static Map<String, String> get values => Map.unmodifiable(_values);
}
