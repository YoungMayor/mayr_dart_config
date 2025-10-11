/// Code generator for creating type-safe configuration accessors.
///
/// This generator reads YAML config files and produces type-safe Dart code
/// with nested class structure for excellent developer experience.
library;

import 'dart:async';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

/// Builder for generating configuration classes from YAML files.
Builder mayrConfigBuilder(BuilderOptions options) => MayrConfigBuilder();

/// Generator that creates type-safe accessors from config YAML files.
///
/// Supports both single file (config.yaml) and multiple files in config/ folder.
/// Generated files match the YAML file names (e.g., app.yaml -> app.g.dart).
class MayrConfigBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.yaml': ['.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    
    // Only process YAML files
    if (inputId.extension != '.yaml') {
      return;
    }

    // Skip non-config files
    final inputPath = inputId.path;
    if (!inputPath.contains('config')) {
      return;
    }

    final configContent = await buildStep.readAsString(inputId);
    final dynamic yamlDoc = loadYaml(configContent);

    if (yamlDoc == null || yamlDoc is! YamlMap) {
      log.warning('${inputId.path} is empty or invalid');
      return;
    }

    // Generate the code
    final generatedCode = _generateCode(yamlDoc, inputPath);

    // Determine output path - same location, change .yaml to .g.dart
    final outputPath = inputPath.replaceAll('.yaml', '.g.dart');
    final outputId = AssetId(buildStep.inputId.package, outputPath);
    
    await buildStep.writeAsString(outputId, generatedCode);
  }

  /// Generate Dart code from the YAML configuration.
  String _generateCode(YamlMap config, String yamlPath) {
    final buffer = StringBuffer();
    
    // Extract file name for class name
    final fileName = path.basenameWithoutExtension(yamlPath);
    final className = _toPascalCase(fileName);

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars');
    buffer.writeln();
    buffer.writeln("import 'package:mayr_config/mayr_config.dart';");
    buffer.writeln();

    // Generate main config class
    buffer.writeln('/// Configuration class for $fileName.');
    buffer.writeln('/// ');
    buffer.writeln('/// Access configuration with type-safe nested syntax:');
    buffer.writeln('/// ```dart');
    
    // Show example usage
    var firstSection = true;
    config.keys.take(2).forEach((key) {
      final getterName = _toCamelCase(key.toString());
      if (config[key] is YamlMap) {
        final nestedKeys = (config[key] as YamlMap).keys.take(1);
        for (var nestedKey in nestedKeys) {
          final nestedGetter = _toCamelCase(nestedKey.toString());
          buffer.writeln('/// final value = $className.$getterName.$nestedGetter;');
          if (firstSection) firstSection = false;
          break;
        }
      }
    });
    buffer.writeln('/// ```');
    buffer.writeln('class $className {');
    buffer.writeln('  $className._();');
    buffer.writeln();

    // Generate static getters for each top-level config section
    config.forEach((key, value) {
      if (value is YamlMap) {
        final getterName = _toCamelCase(key.toString());
        final innerClassName = _toPascalCase(key.toString());
        buffer.writeln('  /// Access $key configuration.');
        buffer.writeln('  static final $getterName = _$innerClassName();');
      }
    });

    buffer.writeln('}');
    buffer.writeln();

    // Generate individual config section classes
    config.forEach((key, value) {
      final sectionName = _toPascalCase(key.toString());

      if (value is YamlMap) {
        buffer.writeln('/// Configuration section for $key.');
        buffer.writeln('class _$sectionName {');
        buffer.writeln('  const _$sectionName();');
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
    // First pass: generate simple getters for leaf values
    map.forEach((key, value) {
      final getterName = _toCamelCase(key.toString());
      final fullKey = '$prefix.$key';

      if (value is! YamlMap) {
        // Leaf value - create a typed getter
        final dartType = _inferType(value);
        buffer.writeln(
          "  $dartType get $getterName => MayrConfig.getValue<$dartType>('$fullKey');",
        );
      }
    });

    // Second pass: generate nested class getters
    map.forEach((key, value) {
      if (value is YamlMap) {
        final getterName = _toCamelCase(key.toString());
        final subClassName = _toPascalCase(key.toString());
        final fullKey = '$prefix.$key';
        
        buffer.writeln();
        buffer.writeln('  /// Access $key configuration.');
        buffer.writeln('  final $getterName = _${subClassName}_Nested();');
      }
    });

    // Third pass: generate nested classes
    map.forEach((key, value) {
      if (value is YamlMap) {
        final subClassName = _toPascalCase(key.toString());
        final fullKey = '$prefix.$key';

        buffer.writeln();
        buffer.writeln('  /// Nested configuration for $key.');
        buffer.writeln('  class _${subClassName}_Nested {');
        buffer.writeln('    const _${subClassName}_Nested();');
        buffer.writeln();

        _generateNestedGetters(buffer, value, fullKey);

        buffer.writeln('  }');
      }
    });
  }

  /// Generate getters for nested configuration values.
  void _generateNestedGetters(StringBuffer buffer, YamlMap map, String prefix) {
    map.forEach((key, value) {
      final getterName = _toCamelCase(key.toString());
      final fullKey = '$prefix.$key';

      if (value is YamlMap) {
        // Nested map - would need deeper nesting, for now treat as Map
        buffer.writeln(
          "    Map<String, dynamic> get $getterName => MayrConfig.getValue<Map<String, dynamic>>('$fullKey');",
        );
      } else {
        // Leaf value
        final dartType = _inferType(value);
        buffer.writeln(
          "    $dartType get $getterName => MayrConfig.getValue<$dartType>('$fullKey');",
        );
      }
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
    if (value is YamlMap || value is Map) return 'Map<String, dynamic>';
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
