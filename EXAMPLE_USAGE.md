# 📝 Example Usage - Proposal 4 in Action

This document shows **real-world usage examples** for the recommended Proposal 4 design.

---

## 🚀 Basic Usage

### 1. Setup Your Config Files

**config.yaml**
```yaml
app:
  name: MyAwesomeApp
  version: 2.0.0
  debug: true
  
api:
  baseUrl: ${API_URL}
  timeout: 5000
  retryAttempts: 3
  
database:
  host: localhost
  port: 5432
  name: myapp_db
  username: admin
  password: ${DB_PASSWORD}
  
features:
  analytics: true
  darkMode: false
  maxUploadSize: 10485760
```

**.env**
```env
API_URL=https://api.production.com
DB_PASSWORD=super_secure_password_123
```

### 2. Load Configuration

**main.dart**
```dart
import 'package:mayr_config/mayr_config.dart';
import 'config.g.dart'; // Generated file

Future<void> main() async {
  // Load config and env in one line
  await MayrConfig.load('config.yaml', '.env');
  
  // Now you can use type-safe config!
  runApp(MyApp());
}
```

### 3. Access Configuration (Type-Safe!)

```dart
import 'config.g.dart';

class ApiService {
  late final String baseUrl;
  late final int timeout;
  late final int retryAttempts;
  
  ApiService() {
    // ✨ Beautiful nested syntax with autocomplete!
    baseUrl = Config.api.baseUrl;        // String
    timeout = Config.api.timeout;        // int
    retryAttempts = Config.api.retryAttempts; // int
    
    // Your IDE knows the types!
    // Autocomplete works perfectly!
    // Refactoring is safe!
  }
  
  Future<Response> makeRequest() async {
    return http.get(
      Uri.parse(baseUrl),
      timeout: Duration(milliseconds: timeout),
    );
  }
}
```

---

## 🎨 Generated Code (What You Get)

**config.g.dart** (automatically generated)
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: public_member_api_docs

import 'package:mayr_config/mayr_config.dart';

/// Main configuration class providing access to all config sections.
class Config {
  Config._();

  /// Access app configuration.
  static final app = _App();
  /// Access api configuration.
  static final api = _Api();
  /// Access database configuration.
  static final database = _Database();
  /// Access features configuration.
  static final features = _Features();
}

/// Configuration class for app.
class _App {
  const _App();

  String get name => MayrConfig.getValue<String>('app.name');
  String get version => MayrConfig.getValue<String>('app.version');
  bool get debug => MayrConfig.getValue<bool>('app.debug');
}

/// Configuration class for api.
class _Api {
  const _Api();

  String get baseUrl => MayrConfig.getValue<String>('api.baseUrl');
  int get timeout => MayrConfig.getValue<int>('api.timeout');
  int get retryAttempts => MayrConfig.getValue<int>('api.retryAttempts');
}

/// Configuration class for database.
class _Database {
  const _Database();

  String get host => MayrConfig.getValue<String>('database.host');
  int get port => MayrConfig.getValue<int>('database.port');
  String get name => MayrConfig.getValue<String>('database.name');
  String get username => MayrConfig.getValue<String>('database.username');
  String get password => MayrConfig.getValue<String>('database.password');
}

/// Configuration class for features.
class _Features {
  const _Features();

  bool get analytics => MayrConfig.getValue<bool>('features.analytics');
  bool get darkMode => MayrConfig.getValue<bool>('features.darkMode');
  int get maxUploadSize => MayrConfig.getValue<int>('features.maxUploadSize');
}
```

---

## 💡 Real-World Examples

### Example 1: Database Connection

```dart
import 'package:postgres/postgres.dart';
import 'config.g.dart';

class DatabaseService {
  late final PostgreSQLConnection connection;
  
  Future<void> connect() async {
    connection = PostgreSQLConnection(
      Config.database.host,       // localhost
      Config.database.port,       // 5432
      Config.database.name,       // myapp_db
      username: Config.database.username,  // admin
      password: Config.database.password,  // super_secure_password_123
    );
    
    await connection.open();
  }
}
```

### Example 2: Feature Flags

```dart
import 'config.g.dart';

class AnalyticsService {
  void trackEvent(String event) {
    // Type-safe boolean check
    if (Config.features.analytics) {
      _sendToAnalytics(event);
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode {
    // Type-safe boolean to enum conversion
    return Config.features.darkMode 
        ? ThemeMode.dark 
        : ThemeMode.light;
  }
}
```

### Example 3: API Client

```dart
import 'package:dio/dio.dart';
import 'config.g.dart';

class ApiClient {
  late final Dio dio;
  
  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: Config.api.baseUrl,           // https://api.production.com
      connectTimeout: Duration(
        milliseconds: Config.api.timeout,    // 5000
      ),
      receiveTimeout: Duration(
        milliseconds: Config.api.timeout,
      ),
    ));
    
    // Add retry interceptor
    dio.interceptors.add(RetryInterceptor(
      retries: Config.api.retryAttempts,     // 3
    ));
  }
}
```

### Example 4: File Upload Validation

```dart
import 'config.g.dart';

class FileUploadService {
  bool canUpload(File file) {
    final fileSize = file.lengthSync();
    final maxSize = Config.features.maxUploadSize; // 10485760 (10MB)
    
    if (fileSize > maxSize) {
      throw Exception(
        'File too large: $fileSize bytes. Max: $maxSize bytes'
      );
    }
    
    return true;
  }
}
```

### Example 5: Conditional UI

```dart
import 'package:flutter/material.dart';
import 'config.g.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.app.name,              // MyAwesomeApp
      debugShowCheckedModeBanner: Config.app.debug, // true
      theme: Config.features.darkMode 
          ? ThemeData.dark() 
          : ThemeData.light(),
      home: HomePage(),
    );
  }
}
```

---

## 🔄 Dynamic Access (When You Need It)

Sometimes you need dynamic access. No problem!

```dart
import 'package:mayr_config/mayr_config.dart';

class ConfigViewer {
  void printAllConfig() {
    // Get all keys dynamically
    for (var key in MayrConfig.keys()) {
      print('$key: ${MayrConfig.get(key)}');
    }
  }
  
  dynamic getUserDefinedKey(String key) {
    // Dynamic access with default value
    return MayrConfig.get(key, 'default');
  }
  
  bool hasFeature(String featureName) {
    // Check if key exists
    return MayrConfig.has('features.$featureName');
  }
}
```

---

## 🧪 Testing

### Testing with Custom Config

```dart
import 'package:test/test.dart';
import 'package:mayr_config/mayr_config.dart';
import 'config.g.dart';

void main() {
  setUp(() async {
    // Load test config
    await MayrConfig.load('test/fixtures/test_config.yaml');
  });
  
  test('API service uses correct timeout', () {
    final service = ApiService();
    
    // Type-safe assertions
    expect(Config.api.timeout, equals(5000));
    expect(service.timeout, equals(5000));
  });
  
  test('Database connection uses correct credentials', () {
    expect(Config.database.host, equals('localhost'));
    expect(Config.database.port, equals(5432));
    expect(Config.database.username, equals('admin'));
  });
  
  tearDown(() {
    MayrConfig.clear();
  });
}
```

---

## 🎭 Comparison: Before and After

### ❌ Before (v1.0.0 - Dynamic, No Type Safety)

```dart
// Loading
await MayrConfig.load(yamlPath: 'config.yaml', envPath: '.env');

// Access - all dynamic!
final name = MayrConfig.get('app.name');           // dynamic ⚠️
final timeout = MayrConfig.get('api.timeout');     // dynamic ⚠️
final debug = MayrConfig.get('app.debug');         // dynamic ⚠️

// Typo? Won't know until runtime!
final typo = MayrConfig.get('api.timout');         // null, no error ⚠️

// No autocomplete, have to remember keys
final url = MayrConfig.get('api.baseUrl');         // Is it baseUrl or base_url? 🤔
```

### ✅ After (v2.0.0 - Type-Safe, Great DX)

```dart
// Loading - simpler!
await MayrConfig.load('config.yaml', '.env');

// Access - type-safe!
final name = Config.app.name;         // String ✅
final timeout = Config.api.timeout;   // int ✅
final debug = Config.app.debug;       // bool ✅

// Typo? IDE catches it immediately!
final typo = Config.api.timout;       // Compile error! ✅
//                     ^^^^^^ 'timout' isn't defined

// Perfect autocomplete!
final url = Config.api.  // IDE shows: baseUrl, timeout, retryAttempts
//                     ^ autocomplete shows all options ✅
```

---

## 🌟 Benefits Demonstrated

### 1. **Type Safety**
```dart
// Compile-time type checking
int timeout = Config.api.timeout;  // ✅ OK
String timeout = Config.api.timeout;  // ❌ Compile error!

// Runtime type checking
MayrConfig.getValue<int>('api.timeout');     // ✅ Returns int
MayrConfig.getValue<String>('api.timeout');  // ❌ Throws TypeMismatch!
```

### 2. **Autocomplete**
```dart
// Type Config. and see all sections
Config.  // ← Shows: app, api, database, features

// Type Config.api. and see all api configs
Config.api.  // ← Shows: baseUrl, timeout, retryAttempts

// Your IDE helps you write code faster!
```

### 3. **Refactoring**
```dart
// Rename 'timeout' to 'requestTimeout' in YAML
// Run build_runner build
// IDE shows all usages that need updating!

// Before: Search for string 'api.timeout' 😰
// After: IDE finds all Config.api.timeout automatically! 🎉
```

### 4. **Safety**
```dart
// Wrong key? Caught at compile time (generated code)
Config.api.timeot;  // ❌ IDE error before you even run!

// Missing config? Clear error message
MayrConfig.getValue<String>('missing.key');
// ❌ Throws: ConfigKeyNotFound('missing.key')
```

---

## 🚀 Getting Started

1. **Add dependency**
   ```yaml
   dependencies:
     mayr_config: ^2.0.0
   
   dev_dependencies:
     build_runner: ^2.4.0
   ```

2. **Create config files**
   - `config.yaml` (your configuration)
   - `.env` (your secrets)

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Use in your app**
   ```dart
   await MayrConfig.load('config.yaml', '.env');
   print(Config.app.name);  // Type-safe! 🎉
   ```

---

## 💬 Questions?

This is the developer experience we're aiming for with Proposal 4. 

**Clean. Simple. Type-safe. Delightful.** ✨

Ready to make this a reality? Let me know and I'll start implementing! 🚀
