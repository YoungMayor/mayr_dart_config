/// MayrConfig - A flexible, type-safe, and environment-aware configuration system.
///
/// This library provides clean configuration management for Dart and Flutter apps.
/// Define your app settings in clean, human-readable YAML files in the `config/`
/// directory, use environment variables with `.env`, and generate type-safe
/// accessors with nested object syntax.
///
/// ## Features
///
/// * Load configuration from YAML files (single or multiple)
/// * Support for environment variables (`.env`)
/// * Dot-notation access (`MayrConfig.get('api.baseUrl')`)
/// * Type-safe code generation with nested objects (`Config.api.baseUrl`)
/// * Built-in validation support
/// * Works in both Dart and Flutter
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:mayr_config/mayr_config.dart';
///
/// Future<void> main() async {
///   // Load single file
///   await MayrConfig.load('config.yaml', '.env');
///
///   // Or load multiple files
///   await MayrConfig.load([
///     'config/app.yaml',
///     'config/api.yaml',
///   ], '.env');
///
///   // Dynamic access
///   print(MayrConfig.get('app.name'));
///   print('api.baseUrl'.config);
///
///   // Type-safe access (after running build_runner)
///   print(App.app.name);
///   print(Api.api.baseUrl);
/// }
/// ```
///
/// ## Type-Safe Access
///
/// Run code generation:
/// ```bash
/// dart run build_runner build
/// ```
///
/// Then use generated classes:
/// ```dart
/// import 'config/app.g.dart';
/// import 'config/api.g.dart';
///
/// final appName = App.app.name;        // String
/// final apiUrl = Api.api.baseUrl;      // String
/// final timeout = Api.api.timeout;     // int
/// ```
///
/// ## Validation
///
/// Add validators before loading:
/// ```dart
/// MayrConfig.addValidator(
///   RequiredKeysValidator(['app.name', 'api.baseUrl'])
/// );
/// await MayrConfig.load('config.yaml');
/// ```
library;

export 'src/core.dart' show MayrConfig, ConfigValidator, RequiredKeysValidator, KeyPatternValidator, TypeValidator;
export 'src/exceptions.dart';
export 'src/extension.dart' show MayrConfigStringExt;
export 'src/generator.dart' show mayrConfigBuilder;

