# Code Generation Tool

This directory contains the standalone code generation tool for MayrConfig.

## Usage

To generate type-safe configuration accessors from your `config.yaml`:

```bash
dart run tool/generate_config.dart [config_path] [output_path]
```

### Examples

Generate from the default `config.yaml` to `lib/config.g.dart`:
```bash
dart run tool/generate_config.dart
```

Generate from a custom path:
```bash
dart run tool/generate_config.dart my_config.yaml lib/my_config.g.dart
```

## What It Does

The generator reads your YAML configuration file and creates Dart classes with type-safe getters for each configuration value.

### Input (config.yaml)
```yaml
app:
  name: MyApp
  debug: true

api:
  baseUrl: https://api.example.com
  timeout: 5000
```

### Output (lib/config.g.dart)
```dart
class AppConfig {
  static String get name => MayrConfig.get('app.name');
  static bool get debug => MayrConfig.get('app.debug');
}

class ApiConfig {
  static String get baseUrl => MayrConfig.get('api.baseUrl');
  static int get timeout => MayrConfig.get('api.timeout');
}
```

### Benefits

- **Type Safety**: Compile-time type checking
- **IDE Support**: Full autocompletion
- **Refactoring**: Safer renames and changes
- **Documentation**: Clear structure of your config

## Type Inference

The generator automatically infers Dart types from YAML values:

- `true/false` → `bool`
- `123` → `int`
- `1.5` → `double`
- `"text"` → `String`
- `[...]` → `List`
- `{...}` → `Map`
