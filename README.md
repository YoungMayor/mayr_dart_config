![License](https://img.shields.io/badge/license-MIT-blue.svg?label=Licence)
![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)

![Pub Version](https://img.shields.io/pub/v/mayr_config?style=plastic&label=Version)
![Pub.dev Score](https://img.shields.io/pub/points/mayr_config?label=Score&style=plastic)
![Pub Likes](https://img.shields.io/pub/likes/mayr_config?label=Likes&style=plastic)
![Pub.dev Publisher](https://img.shields.io/pub/publisher/mayr_config?label=Publisher&style=plastic)
![Downloads](https://img.shields.io/pub/dm/mayr_config.svg?label=Downloads&style=plastic)

![Build Status](https://img.shields.io/github/actions/workflow/status/YoungMayor/mayr_dart_config/ci.yaml?label=Build)
![Issues](https://img.shields.io/github/issues/YoungMayor/mayr_dart_config.svg?label=Issues)
![Last Commit](https://img.shields.io/github/last-commit/YoungMayor/mayr_dart_config.svg?label=Latest%20Commit)
![Contributors](https://img.shields.io/github/contributors/YoungMayor/mayr_dart_config.svg?label=Contributors)


# 🧩 mayr_config

**MayrConfig** brings clean configuration management to Dart and Flutter with a focus on **type safety**, **environment variable support**, and **excellent developer experience**.

Organize your app settings in clean YAML files in the `config/` directory, use environment variables with `.env`, and enjoy **type-safe nested accessors** with perfect autocomplete.

Built with the **Minimal Core with Smart Codegen** architecture for maximum simplicity and maintainability.

---

## ✨ Features

* 🎯 **Type-Safe Access** - Compile-time safety through code generation + runtime type checking
* 🌍 **Environment Variables** - Clean `.env` integration with `${VAR}` interpolation
* 📁 **Multiple Config Files** - Organize configs: `config/app.yaml`, `config/api.yaml`, etc.
* ✅ **Built-in Validation** - Validate required keys and types on load
* 🔄 **Simple API** - One class (`MayrConfig`) does everything
* 🎨 **Nested Structure** - Beautiful syntax: `Config.api.timeout`
* 📝 **Dot-notation Access** - Dynamic access: `MayrConfig.get('api.baseUrl')`
* 🚀 **Works Everywhere** - Dart CLI, Flutter mobile, web, and desktop

---

## 📦 Installation

```bash
dart pub add mayr_config
```

For Flutter:

```bash
flutter pub add mayr_config
```

For code generation (optional but recommended):

```yaml
dev_dependencies:
  build_runner: ^2.4.0
```

---

## 🚀 Quick Start

### 1. Create Config Files

Create a `config/` directory with your YAML files:

**config/app.yaml**
```yaml
app:
  name: MyAwesomeApp
  version: 1.0.0
  debug: true
  environment: ${APP_ENV}
```

**config/api.yaml**
```yaml
api:
  baseUrl: ${API_URL}
  timeout: 5000
  retryAttempts: 3
```

### 2. Create `.env` File

```.env
APP_ENV=development
API_URL=https://api.example.com
```

### 3. Load Configuration

```dart
import 'package:mayr_config/mayr_config.dart';

Future<void> main() async {
  // Load multiple config files
  await MayrConfig.load([
    'config/app.yaml',
    'config/api.yaml',
  ], '.env');

  // Dynamic access
  print(MayrConfig.get('app.name')); // MyAwesomeApp
  print('api.timeout'.config); // 5000

  // Type-safe access
  final timeout = MayrConfig.getValue<int>('api.timeout');
  final debug = MayrConfig.getValue<bool>('app.debug');
}
```

---

## 🎯 Type-Safe Access with Code Generation

Generate type-safe accessors for the best developer experience!

### 1. Run Code Generator

```bash
dart run build_runner build
```

This generates files matching your YAML names:
- `config/app.yaml` → `config/app.g.dart`
- `config/api.yaml` → `config/api.g.dart`

### 2. Import and Use Generated Code

```dart
import 'config/app.g.dart';
import 'config/api.g.dart';

void main() async {
  await MayrConfig.load([
    'config/app.yaml',
    'config/api.yaml',
  ], '.env');

  // Beautiful type-safe nested syntax with autocomplete! ✨
  final appName = App.app.name;           // String
  final version = App.app.version;        // String
  final apiUrl = Api.api.baseUrl;         // String
  final timeout = Api.api.timeout;        // int
  final retries = Api.api.retryAttempts;  // int

  // Your IDE knows all the types!
  // Perfect autocomplete!
  // Refactoring is safe!
}
```

**Generated code example** (`config/app.g.dart`):
```dart
class App {
  App._();
  
  static final app = _App();
}

class _App {
  const _App();
  
  String get name => MayrConfig.getValue<String>('app.name');
  String get version => MayrConfig.getValue<String>('app.version');
  bool get debug => MayrConfig.getValue<bool>('app.debug');
  String get environment => MayrConfig.getValue<String>('app.environment');
}
```

---

## ✅ Built-in Validation

Add validators before loading to catch configuration errors early:

```dart
import 'package:mayr_config/mayr_config.dart';

Future<void> main() async {
  // Ensure required keys exist
  MayrConfig.addValidator(
    RequiredKeysValidator(['app.name', 'api.baseUrl', 'api.timeout']),
  );

  // Validate types
  MayrConfig.addValidator(
    TypeValidator({
      'app.name': String,
      'app.debug': bool,
      'api.timeout': int,
    }),
  );

  // Load config - will throw ConfigValidationError if validation fails
  await MayrConfig.load([
    'config/app.yaml',
    'config/api.yaml',
  ], '.env');
}
```

---

## 🌍 Environment Variables

### Using Environment Variables in YAML

Use `${VAR_NAME}` syntax in your YAML files:

```yaml
api:
  baseUrl: ${API_URL}
  apiKey: ${API_KEY}

database:
  password: ${DB_PASSWORD}
```

### Direct Environment Access

```dart
// Get environment variable directly
final apiUrl = MayrConfig.env('API_URL');
final dbPassword = MayrConfig.env('DB_PASSWORD');

// Get all environment variables
final allEnv = MayrConfig.allEnv;
```

---

## 📖 API Reference

### Loading Configuration

```dart
// Single file
await MayrConfig.load('config.yaml', '.env');

// Multiple files (recommended)
await MayrConfig.load([
  'config/app.yaml',
  'config/api.yaml',
  'config/database.yaml',
], '.env');

// Multiple env files
await MayrConfig.load('config.yaml', ['.env', '.env.local']);
```

### Accessing Values

```dart
// Dynamic access (returns dynamic)
final value = MayrConfig.get('app.name');
final valueWithDefault = MayrConfig.get('missing.key', 'default');

// Type-safe access (throws if key missing or wrong type)
final name = MayrConfig.getValue<String>('app.name');
final timeout = MayrConfig.getValue<int>('api.timeout');
final debug = MayrConfig.getValue<bool>('app.debug');

// Check if key exists
if (MayrConfig.has('app.debug')) {
  // ...
}

// Get all keys
final allKeys = MayrConfig.keys();

// Get all config as map
final allConfig = MayrConfig.all;
```

### String Extension

```dart
// Dynamic access
final name = 'app.name'.config;

// Type-safe access
final timeout = 'api.timeout'.configValue<int>();
final debug = 'app.debug'.configValue<bool>();
```

### Validation

```dart
// Required keys validator
MayrConfig.addValidator(
  RequiredKeysValidator(['app.name', 'api.baseUrl']),
);

// Type validator
MayrConfig.addValidator(
  TypeValidator({
    'app.name': String,
    'api.timeout': int,
  }),
);

// Pattern validator
MayrConfig.addValidator(
  KeyPatternValidator(r'^[a-z]+\.[a-z]+$'),
);

// Clear all validators
MayrConfig.clearValidators();
```

---

## 🎨 Best Practices

### Organize by Feature

```
config/
├── app.yaml       # App-wide settings
├── api.yaml       # API configuration
├── database.yaml  # Database settings
├── cache.yaml     # Cache configuration
└── features.yaml  # Feature flags
```

### Use Environment Variables for Secrets

```yaml
# config/api.yaml
api:
  baseUrl: ${API_URL}      # From .env
  apiKey: ${API_KEY}       # From .env
  timeout: 5000            # Static value
```

```.env
API_URL=https://api.example.com
API_KEY=your_secret_key_here
```

### Add Validation

```dart
void main() async {
  // Validate at startup
  MayrConfig.addValidator(
    RequiredKeysValidator([
      'app.name',
      'app.version',
      'api.baseUrl',
      'api.apiKey',
    ]),
  );

  await MayrConfig.load([
    'config/app.yaml',
    'config/api.yaml',
  ], '.env');
}
```

---

## 💡 Flutter Integration

### Setup

1. Add config files to your assets in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - config/
    - .env
```

2. Load configuration before running your app:

```dart
import 'package:flutter/material.dart';
import 'package:mayr_config/mayr_config.dart';
import 'config/app.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration
  await MayrConfig.load([
    'assets/config/app.yaml',
    'assets/config/api.yaml',
  ], 'assets/.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: App.app.name,  // Type-safe!
      debugShowCheckedModeBanner: App.app.debug,
      home: HomePage(),
    );
  }
}
```

---

## 🧪 Testing

```dart
import 'package:test/test.dart';
import 'package:mayr_config/mayr_config.dart';

void main() {
  setUp(() async {
    MayrConfig.clear();
    await MayrConfig.load('test/fixtures/test_config.yaml');
  });

  tearDown(() {
    MayrConfig.clear();
  });

  test('loads configuration correctly', () {
    expect(MayrConfig.get('app.name'), equals('TestApp'));
    expect(MayrConfig.getValue<int>('api.timeout'), equals(3000));
  });

  test('throws on missing required keys', () {
    MayrConfig.clear();
    MayrConfig.addValidator(
      RequiredKeysValidator(['app.name']),
    );

    expect(
      () => MayrConfig.load('test/fixtures/empty_config.yaml'),
      throwsA(isA<ConfigValidationError>()),
    );
  });
}
```

---

## 🚦 Error Handling

MayrConfig provides clear, specific exceptions:

```dart
try {
  await MayrConfig.load('missing.yaml');
} on ConfigFileNotFound catch (e) {
  print('Config file not found: ${e.path}');
}

try {
  final value = MayrConfig.getValue<String>('missing.key');
} on ConfigKeyNotFound catch (e) {
  print('Key not found: ${e.key}');
}

try {
  final value = MayrConfig.getValue<int>('app.name'); // name is String
} on ConfigTypeMismatch catch (e) {
  print('Type mismatch: ${e.key} (expected ${e.expectedType}, got ${e.actualType})');
}

try {
  await MayrConfig.load('config.yaml');
} on ConfigValidationError catch (e) {
  print('Validation failed: ${e.message}');
}
```

---

## 📚 Examples

Check out the [example](example/) directory for complete working examples:

- **Basic usage** - Simple config loading
- **Multiple files** - Organizing configs by feature
- **Validation** - Using validators
- **Type-safe access** - Generated code usage
- **Flutter integration** - Complete Flutter app example

---

## 🎯 Why MayrConfig?

### Clean Architecture
- **Single core class** - One `MayrConfig` class does everything
- **No overlapping concerns** - Clear separation of runtime vs codegen
- **Minimal codebase** - Easy to understand and maintain

### Type Safety
- **Compile-time safety** - Through code generation
- **Runtime type checking** - With `getValue<T>()`
- **Clear error messages** - Know exactly what went wrong

### Developer Experience
- **Perfect autocomplete** - Your IDE knows all config keys
- **Nested syntax** - Beautiful: `Config.api.timeout`
- **Multiple access patterns** - Generated, dynamic, or extension
- **Easy refactoring** - Rename with confidence

---

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Support

If you find this package helpful, please:
- ⭐ Star the repository
- 🐛 Report issues
- 💡 Suggest features
- 🔀 Submit pull requests

---

## 📧 Contact

- **Author**: Mayor Orimoloye
- **GitHub**: [@YoungMayor](https://github.com/YoungMayor)
- **Issues**: [GitHub Issues](https://github.com/YoungMayor/mayr_dart_config/issues)

---

**Built with ❤️ for the Dart and Flutter community**
dev_dependencies:
  build_runner: ^2.4.15
```

2. **(Required)** Create a `build.yaml` file in your project root:

```yaml
targets:
  $default:
    sources:
      - $package$
      - lib/**
      - config.yaml  # Include your config file as a source
```

> **Note**: The `build.yaml` file is required for build_runner to access your `config.yaml`. This is a standard build_runner requirement and cannot be automated by the package.

3. Run the code generator:

```bash
dart run build_runner build
```

This will generate a `lib/config.g.dart` file with a centralized `Config` class:

```dart
// config.g.dart
class Config {
  Config._();

  static final app = _AppConfig();
  static final api = _ApiConfig();
  static final database = _DatabaseConfig();
}

class _AppConfig {
  const _AppConfig();

  String get name => MayrConfig.get('app.name');
  String get env => MayrConfig.get('app.env');
  bool get debug => MayrConfig.get('app.debug');
}

class _ApiConfig {
  const _ApiConfig();

  String get baseUrl => MayrConfig.get('api.baseUrl');
  int get timeout => MayrConfig.get('api.timeout');
}

class _DatabaseConfig {
  const _DatabaseConfig();

  String get host => MayrConfig.get('database.host');
  int get port => MayrConfig.get('database.port');
  String get username => MayrConfig.get('database.username');
  String get password => MayrConfig.get('database.password');
}
```

Now, you can do:

```dart
print(Config.app.name);
print(Config.api.baseUrl);
print(Config.database.username);
```

✅ No more magic strings
✅ Autocomplete in IDE
✅ Safer refactoring

---

## 🔄 Environment Variables

You can use `.env` values anywhere in your YAML via `${VAR_NAME}` syntax.

The `.env` file is automatically loaded (using [dotenv](https://pub.dev/packages/dotenv)) when calling `MayrConfig.loadFromYaml()`.

---

## 🔍 API Reference

### **MayrConfig**

| Method                                    | Description                          |
| ----------------------------------------- | ------------------------------------ |
| `loadFromYaml(String path)`               | Loads config values from a YAML file |
| `get(String key, [dynamic defaultValue])` | Retrieves a value using dot notation |
| `reload()`                                | Re-reads and reloads the YAML config |
| `keys()`                                  | Returns all config keys              |
| `has(String key)`                         | Checks if a key exists               |

### **String Extension**

```dart
'api.baseUrl'.mayrConfig(); // Shortcut for MayrConfig.get()
```

---

## 🧱 Example Project Structure

```
my_app/
├── lib/
│   └── main.dart
├── config.yaml
├── .env
├── pubspec.yaml
```

---

## 💡 Flutter Integration

In Flutter, simply load your config before `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MayrConfig.loadFromYaml('assets/config.yaml');
  runApp(MyApp());
}
```

You **should** include the config in your assets via `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/config.yaml
    - .env
```

---

## 🛠️ Configuration Reload

You can reload the config at runtime — for instance, after downloading new config from a remote server:

```dart
await MayrConfig.reload();
```

---

## 🧪 Testing Example

```dart
import 'package:test/test.dart';
import 'package:mayr_config/mayr_config.dart';

void main() {
  setUpAll(() async => await MayrConfig.loadFromYaml('config.yaml'));

  test('returns correct config values', () {
    expect(MayrConfig.get('app.name'), equals('MyApp'));
  });
}
```

---

## 🌍 Why YAML?

YAML is clean, readable, and hierarchical — perfect for configuration:

* No messy syntax
* Easy nesting
* Supports environment variable substitution
* Plays well with version control

---

## 📦 Folder Structure (for the package)

```
mayr_config/
├── lib/
│   ├── src/
│   │   ├── core.dart
│   │   ├── env.dart
│   │   ├── loader.dart
│   │   └── generator.dart
│   └── mayr_config.dart
├── example/
│   ├── config.yaml
│   ├── .env
│   ├── main.dart
├── build.yaml
├── pubspec.yaml
```

---

## 📢 Additional Information

### 🤝 Contributing
Contributions are highly welcome!
If you have ideas for new extensions, improvements, or fixes, feel free to fork the repository and submit a pull request.

Please make sure to:
- Follow the existing coding style.
- Write tests for new features.
- Update documentation if necessary.

> Let's build something amazing together!

---

### 🐛 Reporting Issues
If you encounter a bug, unexpected behaviour, or have feature requests:
- Open an issue on the repository.
- Provide a clear description and steps to reproduce (if it's a bug).
- Suggest improvements if you have any ideas.

> Your feedback helps make the package better for everyone!

---

### 🧑‍💻 Author

**MayR Labs**

Crafting clean, reliable, and human-centric Flutter and Dart solutions.
🌍 [mayrlabs.com](https://mayrlabs.com)

---

### 📜 Licence
This package is licensed under the MIT License — which means you are free to use it for commercial and non-commercial projects, with proper attribution.

> See the [LICENSE](LICENSE) file for more details.

MIT © 2025 [MayR Labs](https://github.com/mayrlabs)

---

## 🌟 Support

If you find this package helpful, please consider giving it a ⭐️ on GitHub — it motivates and helps the project grow!

You can also support by:
- Sharing the package with your friends, colleagues, and tech communities.
- Using it in your projects and giving feedback.
- Contributing new ideas, features, or improvements.

> Every little bit of support counts! 🚀💙

