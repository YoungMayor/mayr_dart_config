/// Code generator for creating type-safe configuration accessors.
///
/// This generator reads config.yaml and produces config.g.dart with
/// type-safe getters for all configuration values.
library;

import 'dart:async';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

/// Builder for generating configuration classes from YAML files.
Builder mayrConfigBuilder(BuilderOptions options) => MayrConfigBuilder();

/// Generator that creates type-safe accessors from config.yaml.
class MayrConfigBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$lib$': ['config.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Look for config.yaml in the project root
    final configAssetId = AssetId(buildStep.inputId.package, 'config.yaml');

    if (!await buildStep.canRead(configAssetId)) {
      // config.yaml doesn't exist, skip generation
      return;
    }

    final configContent = await buildStep.readAsString(configAssetId);
    final dynamic yamlDoc = loadYaml(configContent);

    if (yamlDoc == null || yamlDoc is! YamlMap) {
      log.warning('config.yaml is empty or invalid');
      return;
    }

    final generatedCode = _generateCode(yamlDoc);

    final outputId = AssetId(buildStep.inputId.package, 'lib/config.g.dart');
    await buildStep.writeAsString(outputId, generatedCode);
  }

  /// Generate Dart code from the YAML configuration.
  String _generateCode(YamlMap config) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: public_member_api_docs');
    buffer.writeln();
    buffer.writeln("import 'package:mayr_config/mayr_config.dart';");
    buffer.writeln();

    // Generate classes for each top-level key
    config.forEach((key, value) {
      final className = _toPascalCase(key.toString());

      if (value is YamlMap) {
        buffer.writeln('/// Configuration class for $key.');
        buffer.writeln('class ${className}Config {');
        buffer.writeln('  ${className}Config._();');
        buffer.writeln();

        _generateGetters(buffer, value, key.toString());

        buffer.writeln('}');
        buffer.writeln();
      }
    });

    return buffer.toString();
  }

  /// Generate getter methods for configuration values.
  void _generateGetters(StringBuffer buffer, YamlMap map, String prefix) {
    map.forEach((key, value) {
      final getterName = _toCamelCase(key.toString());
      final fullKey = '$prefix.$key';

      if (value is YamlMap) {
        // Nested map - create a sub-class getter
        final subClassName = _toPascalCase(key.toString());
        buffer.writeln('  static final $getterName = _$subClassName();');
      } else {
        // Leaf value - create a direct getter
        final dartType = _inferType(value);
        buffer.writeln(
          "  static $dartType get $getterName => MayrConfig.get('$fullKey');",
        );
      }
    });

    // Generate nested classes
    map.forEach((key, value) {
      if (value is YamlMap) {
        final subClassName = _toPascalCase(key.toString());
        final fullKey = '$prefix.$key';

        buffer.writeln();
        buffer.writeln('class _$subClassName {');
        buffer.writeln('  const _$subClassName();');
        buffer.writeln();

        _generateNestedGetters(buffer, value, fullKey);

        buffer.writeln('}');
        buffer.writeln();
      }
    });
  }

  /// Generate getters for nested configuration values.
  void _generateNestedGetters(StringBuffer buffer, YamlMap map, String prefix) {
    map.forEach((key, value) {
      final getterName = _toCamelCase(key.toString());
      final fullKey = '$prefix.$key';
      final dartType = _inferType(value);

      buffer.writeln(
        "  $dartType get $getterName => MayrConfig.get('$fullKey');",
      );
    });
  }

  /// Infer Dart type from YAML value.
  String _inferType(dynamic value) {
    if (value == null) return 'dynamic';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is YamlList || value is List) return 'List';
    if (value is YamlMap || value is Map) return 'Map';
    return 'dynamic';
  }

  /// Convert a string to PascalCase.
  String _toPascalCase(String input) {
    if (input.isEmpty) return input;

    return input
        .split(RegExp(r'[_\-\s]'))
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join('');
  }

  /// Convert a string to camelCase.
  String _toCamelCase(String input) {
    if (input.isEmpty) return input;

    final pascal = _toPascalCase(input);
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
