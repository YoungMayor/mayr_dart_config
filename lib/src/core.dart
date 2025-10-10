/// Core singleton class for storing and accessing configuration values.
///
/// This class handles:
/// - Holding parsed configuration map
/// - Performing YAML flattening
/// - Providing `get(key)` access
/// - Reloading config at runtime
library;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'env.dart';

/// Singleton core storage and access layer for all loaded configs.
class MayrConfigCore {
  static final MayrConfigCore _instance = MayrConfigCore._internal();

  factory MayrConfigCore() => _instance;

  MayrConfigCore._internal();

  /// Flattened configuration map using dot notation.
  final Map<String, dynamic> _config = {};

  /// Path to the last loaded YAML file.
  String? _yamlPath;

  /// Path to the last loaded .env file.
  String? _envPath;

  /// Load configuration from a YAML file.
  ///
  /// This method reads the YAML file, interpolates environment variables,
  /// and flattens the nested structure into dot notation.
  Future<void> loadFromYaml(String path) async {
    _yamlPath = path;
    final file = File(path);

    if (!await file.exists()) {
      throw FileSystemException('Config file not found', path);
    }

    final content = await file.readAsString();
    final dynamic yamlDoc = loadYaml(content);

    if (yamlDoc == null) {
      return;
    }

    // Convert YamlMap to regular Map and flatten
    final Map<String, dynamic> data = _yamlToMap(yamlDoc);
    _config.clear();
    _flattenMap(data, '');
  }

  /// Load environment variables from a .env file.
  Future<void> loadEnv(String path) async {
    _envPath = path;
    await MayrEnv.load(path);
  }

  /// Get a configuration value by key using dot notation.
  ///
  /// Returns [defaultValue] if the key is not found.
  dynamic get(String key, [dynamic defaultValue]) {
    return _config[key] ?? defaultValue;
  }

  /// Check if a configuration key exists.
  bool has(String key) {
    return _config.containsKey(key);
  }

  /// Get all configuration keys.
  Iterable<String> keys() {
    return _config.keys;
  }

  /// Clear all configuration values.
  void clear() {
    _config.clear();
  }

  /// Reload configuration from the last loaded files.
  Future<void> reload() async {
    if (_envPath != null) {
      await loadEnv(_envPath!);
    }
    if (_yamlPath != null) {
      await loadFromYaml(_yamlPath!);
    }
  }

  /// Convert YAML data structures to regular Dart maps and lists.
  dynamic _yamlToMap(dynamic node) {
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
  void _flattenMap(Map<String, dynamic> map, String prefix) {
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
  String _interpolateEnvVars(String value) {
    final pattern = RegExp(r'\$\{([^}]+)\}');
    return value.replaceAllMapped(pattern, (match) {
      final varName = match.group(1);
      if (varName == null) return match.group(0)!;

      final envValue = MayrEnv.get(varName);
      return envValue ?? match.group(0)!;
    });
  }
}
