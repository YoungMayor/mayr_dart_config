/// Unified core class for configuration management.
///
/// This is the single source of truth for all configuration in Proposal 4.
/// Handles environment loading, YAML parsing, interpolation, and validation.
library;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'exceptions.dart';

/// Main configuration class - handles everything!
///
/// This unified class provides:
/// - Environment variable loading from .env files
/// - YAML configuration loading with ${VAR} interpolation
/// - Dot-notation flattened access
/// - Type-safe getValue<T>() method
/// - Built-in validation support
/// - Multiple config file support
class MayrConfig {
  // Private constructor to prevent instantiation
  MayrConfig._();

  /// Flattened configuration map using dot notation.
  static final Map<String, dynamic> _config = {};

  /// Environment variables loaded from .env files.
  static final Map<String, String> _env = {};

  /// Loaded config file paths for potential reload.
  static final List<String> _configPaths = [];

  /// Loaded env file paths.
  static final List<String> _envPaths = [];

  /// Validation rules.
  static final List<ConfigValidator> _validators = [];

  /// Load configuration from YAML file(s) and optional .env file(s).
  ///
  /// Supports both single file and multiple files:
  /// ```dart
  /// // Single file
  /// await MayrConfig.load('config.yaml', '.env');
  ///
  /// // Multiple files
  /// await MayrConfig.load([
  ///   'config/app.yaml',
  ///   'config/api.yaml',
  /// ], '.env');
  /// ```
  static Future<void> load(
    dynamic configPath, [
    dynamic envPath,
  ]) async {
    // Load environment variables first
    if (envPath != null) {
      if (envPath is String) {
        await _loadEnvFile(envPath);
      } else if (envPath is List<String>) {
        for (var path in envPath) {
          await _loadEnvFile(path);
        }
      }
    }

    // Load configuration files
    if (configPath is String) {
      await _loadYamlFile(configPath);
    } else if (configPath is List<String>) {
      for (var path in configPath) {
        await _loadYamlFile(path);
      }
    } else {
      throw ArgumentError('configPath must be String or List<String>');
    }

    // Run validators
    _runValidators();
  }

  /// Load a single .env file.
  static Future<void> _loadEnvFile(String path) async {
    _envPaths.add(path);
    final file = File(path);

    if (!await file.exists()) {
      // .env files are optional
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
      _env[key] = unquotedValue;
    }
  }

  /// Load a single YAML configuration file.
  static Future<void> _loadYamlFile(String path) async {
    _configPaths.add(path);
    final file = File(path);

    if (!await file.exists()) {
      throw ConfigFileNotFound(path);
    }

    final content = await file.readAsString();
    final dynamic yamlDoc = loadYaml(content);

    if (yamlDoc == null) {
      return;
    }

    // Convert YamlMap to regular Map and flatten
    final Map<String, dynamic> data = _yamlToMap(yamlDoc);
    _flattenMap(data, '');
  }

  /// Get a configuration value by key using dot notation.
  ///
  /// Returns [defaultValue] if the key is not found.
  ///
  /// Example:
  /// ```dart
  /// final name = MayrConfig.get('app.name');
  /// final timeout = MayrConfig.get('api.timeout', 5000);
  /// ```
  static dynamic get(String key, [dynamic defaultValue]) {
    return _config[key] ?? defaultValue;
  }

  /// Get a type-safe configuration value.
  ///
  /// Throws [ConfigKeyNotFound] if key doesn't exist.
  /// Throws [ConfigTypeMismatch] if value is not of type T.
  ///
  /// Example:
  /// ```dart
  /// final timeout = MayrConfig.getValue<int>('api.timeout');
  /// final debug = MayrConfig.getValue<bool>('app.debug');
  /// ```
  static T getValue<T>(String key) {
    if (!_config.containsKey(key)) {
      throw ConfigKeyNotFound(key);
    }

    final value = _config[key];
    
    if (value is! T) {
      throw ConfigTypeMismatch(key, T, value.runtimeType);
    }

    return value;
  }

  /// Check if a configuration key exists.
  static bool has(String key) {
    return _config.containsKey(key);
  }

  /// Get all configuration keys.
  static Iterable<String> keys() {
    return _config.keys;
  }

  /// Get all configuration as a map.
  static Map<String, dynamic> get all => Map.unmodifiable(_config);

  /// Get an environment variable value.
  static String? env(String key) {
    return _env[key];
  }

  /// Get all environment variables.
  static Map<String, String> get allEnv => Map.unmodifiable(_env);

  /// Add a validator to run on config load.
  ///
  /// Example:
  /// ```dart
  /// MayrConfig.addValidator(
  ///   RequiredKeysValidator(['app.name', 'api.baseUrl'])
  /// );
  /// ```
  static void addValidator(ConfigValidator validator) {
    _validators.add(validator);
  }

  /// Clear all validators.
  static void clearValidators() {
    _validators.clear();
  }

  /// Clear all configuration and environment variables.
  ///
  /// Useful for testing.
  static void clear() {
    _config.clear();
    _env.clear();
    _configPaths.clear();
    _envPaths.clear();
  }

  /// Run all registered validators.
  static void _runValidators() {
    for (var validator in _validators) {
      validator.validate(_config);
    }
  }

  /// Convert YAML data structures to regular Dart maps and lists.
  static dynamic _yamlToMap(dynamic node) {
    if (node is YamlMap) {
      final map = <String, dynamic>{};
      node.forEach((key, value) {
        map[key.toString()] = _yamlToMap(value);
      });
      return map;
    } else if (node is YamlList) {
      return node.map((item) => _yamlToMap(item)).toList();
    } else if (node is String) {
      // Interpolate environment variables
      return _interpolateEnvVars(node);
    } else {
      return node;
    }
  }

  /// Flatten a nested map into dot notation.
  static void _flattenMap(Map<String, dynamic> map, String prefix) {
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        _flattenMap(value, newKey);
      } else {
        _config[newKey] = value;
      }
    });
  }

  /// Interpolate environment variables in a string.
  ///
  /// Replaces ${VAR_NAME} with the corresponding environment variable value.
  static String _interpolateEnvVars(String value) {
    final pattern = RegExp(r'\$\{([^}]+)\}');
    return value.replaceAllMapped(pattern, (match) {
      final varName = match.group(1);
      if (varName == null) return match.group(0)!;

      final envValue = _env[varName];
      return envValue ?? match.group(0)!;
    });
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
}

/// Base class for configuration validators.
abstract class ConfigValidator {
  /// Validate the configuration.
  ///
  /// Should throw [ConfigValidationError] if validation fails.
  void validate(Map<String, dynamic> config);
}

/// Validator that ensures required keys exist.
class RequiredKeysValidator extends ConfigValidator {
  final List<String> requiredKeys;

  RequiredKeysValidator(this.requiredKeys);

  @override
  void validate(Map<String, dynamic> config) {
    final missing = <String>[];
    
    for (var key in requiredKeys) {
      if (!config.containsKey(key)) {
        missing.add(key);
      }
    }

    if (missing.isNotEmpty) {
      throw ConfigValidationError(
        'Missing required configuration keys: ${missing.join(', ')}',
      );
    }
  }
}

/// Validator that ensures keys match a pattern.
class KeyPatternValidator extends ConfigValidator {
  final String keyPattern;
  final RegExp pattern;

  KeyPatternValidator(this.keyPattern) : pattern = RegExp(keyPattern);

  @override
  void validate(Map<String, dynamic> config) {
    final invalid = <String>[];

    for (var key in config.keys) {
      if (!pattern.hasMatch(key)) {
        invalid.add(key);
      }
    }

    if (invalid.isNotEmpty) {
      throw ConfigValidationError(
        'Invalid configuration keys: ${invalid.join(', ')}',
      );
    }
  }
}

/// Validator for type checking configuration values.
class TypeValidator extends ConfigValidator {
  final Map<String, Type> typeMap;

  TypeValidator(this.typeMap);

  @override
  void validate(Map<String, dynamic> config) {
    final errors = <String>[];

    typeMap.forEach((key, expectedType) {
      if (config.containsKey(key)) {
        final value = config[key];
        if (value.runtimeType != expectedType) {
          errors.add(
            '$key: expected $expectedType, got ${value.runtimeType}',
          );
        }
      }
    });

    if (errors.isNotEmpty) {
      throw ConfigValidationError(
        'Type validation failed:\n${errors.join('\n')}',
      );
    }
  }
}
