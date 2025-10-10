/// MayrConfig - A flexible, type-safe, and environment-aware configuration system.
///
/// This library provides clean configuration management for Dart and Flutter apps.
/// Define your app settings in a clean, human-readable `config.yaml` file,
/// use environment variables with `.env`, and generate type-safe accessors.
///
/// ## Features
///
/// * Load configuration from `config.yaml`
/// * Support for environment variables (`.env`)
/// * Dot-notation access (`MayrConfig.get('api.baseUrl')`)
/// * Optional code generation for type-safe accessors
/// * Hot reloadable at runtime
/// * Works in both Dart and Flutter
///
/// ## Usage
///
/// ```dart
/// import 'package:mayr_config/mayr_config.dart';
///
/// Future<void> main() async {
///   await MayrConfig.loadFromYaml('config.yaml');
///
///   print(MayrConfig.get('app.name'));
///   print('api.baseUrl'.mayrConfig());
/// }
/// ```
library;

export 'src/core.dart' show MayrConfigCore;
export 'src/env.dart' show MayrEnv;
export 'src/loader.dart' show MayrConfig;
export 'src/extension.dart' show MayrConfigStringExt;
