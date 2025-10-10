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

**MayrConfig** brings clean configuration management to Dart and Flutter.
Define your app settings in a clean, human-readable `config.yaml` file, use environment variables with `.env`, and even generate **type-safe accessors** for autocompletion and compile-time safety.

Simple, elegant, and built for real-world apps.

---

## 🚀 Features

* ✅ Load configuration from `config.yaml`
* ✅ Support for environment variables (`.env`)
* ✅ Dot-notation access (`MayrConfig.get('api.baseUrl')`)
* ✅ Optional **code generation** for type-safe accessors
* ✅ Hot reloadable at runtime (re-load file anytime)
* ✅ Works in both **Dart** and **Flutter**

---

## 📦 Installation

```bash
dart pub add mayr_config
```

For Flutter:

```bash
flutter pub add mayr_config
```

---

## ⚙️ Usage

### 1. Create a `config.yaml`

```yaml
# config.yaml
app:
  name: MyApp
  env: ${APP_ENV}
  debug: true

api:
  baseUrl: ${API_URL}
  timeout: 5000

database:
  host: localhost
  port: 3306
  username: root
  password: secret
```

### 2. Create a `.env`

```
APP_ENV=production
API_URL=https://api.example.com
```

### 3. Load your configuration

```dart
import 'package:mayr_config/mayr_config.dart';

Future<void> main() async {
  await MayrConfig.loadFromYaml('config.yaml');

  print(MayrConfig.get('app.name')); // MyApp
  print('api.baseUrl'.mayrConfig()); // https://api.example.com
}
```

---

## 🧠 Type-Safe Access (Code Generation)

To get autocompletion and type-safety, run:

```bash
dart run build_runner build
```

> **Note**: Make sure your `config.yaml` is in the project root. If you're using this package as a dependency, the code generation will work automatically when you run `build_runner` in your project.

This will generate a file like `config.g.dart` containing structured accessors:

```dart
// config.g.dart
class AppConfig {
  AppConfig._();
  
  static String get name => MayrConfig.get('app.name');
  static String get env => MayrConfig.get('app.env');
  static bool get debug => MayrConfig.get('app.debug');
}

class ApiConfig {
  ApiConfig._();
  
  static String get baseUrl => MayrConfig.get('api.baseUrl');
  static int get timeout => MayrConfig.get('api.timeout');
}

class DatabaseConfig {
  DatabaseConfig._();
  
  static String get host => MayrConfig.get('database.host');
  static int get port => MayrConfig.get('database.port');
  static String get username => MayrConfig.get('database.username');
  static String get password => MayrConfig.get('database.password');
}
```

Now, you can do:

```dart
print(AppConfig.name);
print(ApiConfig.baseUrl);
print(DatabaseConfig.username);
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

