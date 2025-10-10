
# 🧩 DESIGN.md — MayrConfig

## Overview

**MayrConfig** provides a flexible, type-safe, and environment-aware configuration system for Dart and Flutter apps.
It draws inspiration from **Laravel’s config system**, enabling developers to define app-wide configuration values in a simple `config.yaml` file, with support for `.env` substitution and **auto-generated Dart accessors** for type-safe usage.

---

## 🎯 Core Goals

1. **Human-readable configs** via YAML
2. **Environment-aware values** using `.env` interpolation
3. **Type-safe code generation** for autocompletion and static analysis
4. **Zero boilerplate** runtime access through `MayrConfig.get()` and `"key".mayrConfig()`
5. **Hot-reloadable** configuration (can re-load at runtime)

---

## ⚙️ Architecture

### 1. Components

| Component               | Responsibility                                                                            |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| **MayrConfigCore**      | Singleton storage and access layer for all loaded configs                                 |
| **MayrConfig**          | Public API for reading values and loading config files                                    |
| **MayrConfigGenerator** | Code generator that reads `config.yaml` and produces `config.g.dart` with typed accessors |
| **MayrEnv**             | Lightweight `.env` loader and interpolator                                                |
| **MayrConfigExtension** | Adds `"config.key".mayrConfig()` sugar syntax                                             |

---

### 2. Example Usage

**config.yaml**

```yaml
app:
  name: MayR Events
  debug: true
  locale: en

api:
  baseUrl: ${API_URL}
  timeout: 5000

database:
  host: localhost
  port: 3306
  username: root
  password: ${DB_PASSWORD}
```

**.env**

```
APP_NAME=Mayr Events
API_URL=https://api.mayrevents.com
DB_PASSWORD=supersecret
```

**main.dart**

```dart
import 'package:mayr_config/mayr_config.dart';
import 'config.g.dart'; // generated file

void main() async {
  await MayrConfig.load(); // auto-loads config.yaml + .env

  print(AppConfig.name); // Mayr Events
  print(ApiConfig.baseUrl); // https://api.mayrevents.com  - Gotten from env, not added to the  config.g.dart file
  print(MayrConfig.get('database.host')); // localhost  -  Gotten from env, not added to the  config.g.dart file
  print('database.username'.mayrConfig()); // root
}
```

---

## 🧠 How It Works

### Step 1 — Load configuration

When `MayrConfig.load()` is called:

* It loads environment variables from `.env`
* Reads and parses `config.yaml`
* Interpolates `${VAR}` syntax with `.env` values
* Flattens nested maps into dot notation
* Stores everything in `MayrConfigCore`

### Step 2 — Generate typed accessors

When `build_runner` runs, the generator:

* Scans `config.yaml`
* Generates a file `config.g.dart` containing type-safe getters

Example output:

```dart
// GENERATED FILE - DO NOT MODIFY BY HAND

import 'package:mayr_config/mayr_config.dart';

class AppConfig {
  static String get name => MayrConfig.get('app.name');
  static bool get debug => MayrConfig.get('app.debug');
  static String get locale => MayrConfig.get('app.locale');
}

class ApiConfig {
  static String get baseUrl => MayrConfig.get('api.baseUrl');
  static int get timeout => MayrConfig.get('api.timeout');
}

class DatabaseConfig {
  static String get host => MayrConfig.get('database.host');
  static int get port => MayrConfig.get('database.port');
  static String get username => MayrConfig.get('database.username');
  static String get password => MayrConfig.get('database.password');
}
```

Developers can now do:

```dart
print(AppConfig.name);
print(ApiConfig.timeout);
```

and get full IDE autocompletion.

---

## 🧩 Core Classes

### `MayrConfigCore` (Singleton)

Responsible for:

* Holding parsed configuration map
* Performing YAML flattening
* Providing `get(key)` access
* Reloading config at runtime

**Key methods**

```dart
Future<void> loadFromYaml(String path);
Future<void> loadEnv(String path);
dynamic get(String key, [dynamic defaultValue]);
void clear();
```

---

### `MayrConfig`

Public-facing API for users. Wraps around the core singleton.

```dart
class MayrConfig {
  static Future<void> load({
    String yamlPath = 'config.yaml',
    String envPath = '.env',
  });

  static dynamic get(String key, [dynamic defaultValue]);
}
```

---

### `MayrEnv`

Tiny helper for loading `.env` files.

```dart
class MayrEnv {
  static final Map<String, String> values = {};

  static Future<void> load([String path = '.env']);
  static String? get(String key);
}
```

Interpolation happens when `${VAR}` is encountered in YAML.

---

### `MayrConfigExtension`

Syntactic sugar:

```dart
extension MayrConfigStringExt on String {
  dynamic mayrConfig([dynamic defaultValue]) =>
      MayrConfig.get(this, defaultValue);
}
```

Usage:

```dart
'api.baseUrl'.mayrConfig();
```

---

### `MayrConfigGenerator`

Custom code generator (via `build_runner`) that:

* Reads `config.yaml`
* Creates a `config.g.dart`
* Maps nested keys to generated classes

---

## 🔮 Code Generation Design

| Input            | Output                                        |
| ---------------- | --------------------------------------------- |
| YAML nested keys | Nested Dart classes                           |
| Non-map values   | Static getters                                |
| Key casing       | PascalCase for classes, camelCase for getters |
| Supported types  | String, int, double, bool, List, Map          |

---

## ⚡️ Example Directory Structure

```
project/
├── lib/
│   ├── main.dart
│   ├── config.g.dart       # generated file
│   ├── mayr_config.dart
├── config.yaml
├── .env
├── build.yaml              # generator config
├── pubspec.yaml
```

---

## 🧩 API Summary

| Method / Property                | Description                          |
| -------------------------------- | ------------------------------------ |
| `MayrConfig.load()`              | Loads both YAML and .env             |
| `MayrConfig.get(key, [default])` | Get flattened key                    |
| `"key".mayrConfig()`             | String extension sugar               |
| `AppConfig.fieldName`            | Type-safe getter from generated file |
| `MayrEnv.get(key)`               | Get environment variable directly    |
| `MayrConfig.reload()`            | Reload configs dynamically           |

---

## 🚀 Example Workflow

1. Create `.env` and `config.yaml`
2. Run:

   ```bash
   dart run build_runner build
   ```
3. Import and use:

   ```dart
   import 'config.g.dart';
   print(ApiConfig.baseUrl);
   ```
4. Optional: reload configs dynamically in runtime (e.g., Flutter hot reload)

---

## 🧱 Future Extensions

* `MayrConfig.watch()` to auto-reload on file change (for dev environments)
* Support for `config/` folder with multiple files (`config/app.yaml`, `config/api.yaml`, etc.)
* Type inference improvements in generator (detect int, bool, etc. automatically)
* Validation on config load (e.g., required keys)

---

## 🧩 Example Output Summary

**config.yaml**

```yaml
app:
  name: MyApp
  debug: true
  locale: en
```

**Generated**

```dart
class AppConfig {
  static String get name => MayrConfig.get('app.name');
  static bool get debug => MayrConfig.get('app.debug');
  static String get locale => MayrConfig.get('app.locale');
}
```

**Usage**

```dart
print(AppConfig.name);
print('app.debug'.mayrConfig());
```
