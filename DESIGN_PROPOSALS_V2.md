# MayrConfig V2.0 - Design Proposals

## Current State Analysis

The v1.0.0 package works but has some architectural issues:
- Multiple overlapping concerns (Core, Loader, separate Env handling)
- Code generation is separate and not tightly integrated
- Environment variable handling feels bolted on
- API surface is a bit scattered

## Core Requirements (Priority Order)

1. **Type Safety** - Compile-time safety for configuration access
2. **Environment Variable Support** - Clean .env integration with interpolation
3. **Clean API** - Simple, intuitive usage
4. Secondary: Hot reload, validation, nested access

---

## 🎨 Proposal 1: **Unified Core with Type-Safe Builders**

### Philosophy
Single responsibility classes with a focus on type safety through builders and generic methods.

### Architecture

```dart
// Single core class that handles everything
class ConfigLoader {
  final Map<String, dynamic> _values = {};
  final Map<String, String> _env = {};
  
  Future<void> load({String? yaml, String? env}) async {
    if (env != null) await _loadEnv(env);
    if (yaml != null) await _loadYaml(yaml);
  }
  
  // Type-safe getters with generics
  T get<T>(String key, {T? defaultValue}) {
    final value = _values[key] ?? defaultValue;
    if (value is! T) throw TypeError();
    return value;
  }
  
  String getString(String key, {String? defaultValue}) => 
    get<String>(key, defaultValue: defaultValue);
  
  int getInt(String key, {int? defaultValue}) => 
    get<int>(key, defaultValue: defaultValue);
  
  bool getBool(String key, {bool? defaultValue}) => 
    get<bool>(key, defaultValue: defaultValue);
}

// Simple global instance
final config = ConfigLoader();

// Code generation produces:
class Config {
  static String get appName => config.getString('app.name');
  static String get apiBaseUrl => config.getString('api.baseUrl');
  static int get apiTimeout => config.getInt('api.timeout');
}
```

### Usage
```dart
await config.load(yaml: 'config.yaml', env: '.env');

// Type-safe access
String name = Config.appName;
int timeout = Config.apiTimeout;

// Runtime access (type-safe with generics)
String name = config.getString('app.name');
int timeout = config.getInt('api.timeout', defaultValue: 5000);
```

### Pros
- ✅ Simple, single class to understand
- ✅ Strong type safety with generics
- ✅ Clean separation between generated and runtime access
- ✅ Minimal API surface

### Cons
- ❌ Requires explicit type methods (getString, getInt, etc.)
- ❌ Code generation less flexible for nested structures

---

## 🎨 Proposal 2: **Layered Architecture with Config Providers**

### Philosophy
Separation of concerns with provider pattern. Each layer has a single responsibility.

### Architecture

```dart
// Layer 1: Environment provider
class EnvProvider {
  static final Map<String, String> _env = {};
  
  static Future<void> load(String path) async { ... }
  static String? operator [](String key) => _env[key];
}

// Layer 2: Config provider  
class ConfigProvider {
  final Map<String, dynamic> _config = {};
  
  Future<void> load(String path) async {
    // Load, interpolate with EnvProvider, flatten
  }
  
  T? call<T>(String key, [T? defaultValue]) {
    return (_config[key] ?? defaultValue) as T?;
  }
}

// Layer 3: Type-safe facade
class Config {
  static final _provider = ConfigProvider();
  
  static Future<void> init({
    required String configPath,
    String? envPath,
  }) async {
    if (envPath != null) await EnvProvider.load(envPath);
    await _provider.load(configPath);
  }
  
  // Generic get with type inference
  static T get<T>(String key, [T? defaultValue]) {
    return _provider<T>(key, defaultValue);
  }
}

// Generated code
extension AppConfig on Config {
  static String get name => Config.get<String>('app.name')!;
  static bool get debug => Config.get<bool>('app.debug') ?? false;
}

extension ApiConfig on Config {
  static String get baseUrl => Config.get<String>('api.baseUrl')!;
  static int get timeout => Config.get<int>('api.timeout') ?? 5000;
}
```

### Usage
```dart
await Config.init(
  configPath: 'config.yaml',
  envPath: '.env',
);

// Generated type-safe access
String name = AppConfig.name;
String url = ApiConfig.baseUrl;

// Dynamic access
String name = Config.get('app.name');
```

### Pros
- ✅ Clear separation of concerns
- ✅ Testable layers
- ✅ Flexible for complex scenarios
- ✅ Nice extension-based generated code

### Cons
- ❌ More files/classes to understand
- ❌ Extensions might be confusing

---

## 🎨 Proposal 3: **Functional Style with Immutable Config**

### Philosophy
Immutable configuration object with functional access patterns.

### Architecture

```dart
// Immutable config object
class AppConfig {
  final Map<String, dynamic> _values;
  
  const AppConfig._(this._values);
  
  static Future<AppConfig> load({
    required String yaml,
    String? env,
  }) async {
    final envVars = env != null ? await _loadEnv(env) : <String, String>{};
    final values = await _loadYaml(yaml, envVars);
    return AppConfig._(values);
  }
  
  // Type-safe getters with Maybe pattern
  ConfigValue<T> get<T>(String key) {
    return ConfigValue<T>(_values[key]);
  }
  
  // Direct access
  T? operator [](String key) => _values[key];
}

// Maybe monad for config values
class ConfigValue<T> {
  final dynamic _value;
  
  ConfigValue(this._value);
  
  T get value => _value as T;
  T or(T defaultValue) => _value ?? defaultValue;
  T? get orNull => _value as T?;
  
  bool get exists => _value != null;
}

// Generated code creates typed accessors
class GeneratedConfig {
  final AppConfig _config;
  
  GeneratedConfig(this._config);
  
  String get appName => _config.get<String>('app.name').value;
  bool get appDebug => _config.get<bool>('app.debug').or(false);
  
  Api get api => Api(_config);
}

class Api {
  final AppConfig _config;
  Api(this._config);
  
  String get baseUrl => _config.get<String>('api.baseUrl').value;
  int get timeout => _config.get<int>('api.timeout').or(5000);
}
```

### Usage
```dart
final config = await AppConfig.load(
  yaml: 'config.yaml',
  env: '.env',
);

final generated = GeneratedConfig(config);

// Type-safe generated access
String name = generated.appName;
String url = generated.api.baseUrl;

// Dynamic functional access
String name = config.get<String>('app.name').value;
int timeout = config.get<int>('api.timeout').or(5000);
```

### Pros
- ✅ Immutable and pure functional
- ✅ Excellent for testing
- ✅ Clear error handling with Maybe pattern
- ✅ Generated code feels natural (nested objects)

### Cons
- ❌ More boilerplate for simple use cases
- ❌ Functional concepts may be unfamiliar to some

---

## 🎨 Proposal 4: **Minimal Core with Smart Codegen** (RECOMMENDED)

### Philosophy
Ultra-simple runtime API. Let code generation do the heavy lifting for type safety.

### Architecture

```dart
// Single simple class
class MayrConfig {
  static final _config = <String, dynamic>{};
  static final _env = <String, String>{};
  
  static Future<void> load(String configPath, [String? envPath]) async {
    if (envPath != null) {
      _env.addAll(await _parseEnv(envPath));
    }
    _config.addAll(await _parseYaml(configPath, _env));
  }
  
  // Simple dynamic access
  static dynamic get(String key, [dynamic defaultValue]) {
    return _config[key] ?? defaultValue;
  }
  
  // Type-safe access (throws if wrong type)
  static T getValue<T>(String key, [T? defaultValue]) {
    final value = _config[key] ?? defaultValue;
    if (value == null) throw ConfigKeyNotFound(key);
    if (value is! T) throw ConfigTypeMismatch(key, T, value.runtimeType);
    return value;
  }
}

// Extension for convenience
extension ConfigString on String {
  T config<T>([T? defaultValue]) => MayrConfig.getValue<T>(this, defaultValue);
  dynamic get config => MayrConfig.get(this);
}

// Smart generated code with nested classes
class Config {
  Config._();
  
  static final app = _App();
  static final api = _Api();
  static final database = _Database();
}

class _App {
  String get name => MayrConfig.getValue<String>('app.name');
  String get env => MayrConfig.getValue<String>('app.env');
  bool get debug => MayrConfig.getValue<bool>('app.debug');
}

class _Api {
  String get baseUrl => MayrConfig.getValue<String>('api.baseUrl');
  int get timeout => MayrConfig.getValue<int>('api.timeout');
}

class _Database {
  String get host => MayrConfig.getValue<String>('database.host');
  int get port => MayrConfig.getValue<int>('database.port');
  String get password => MayrConfig.getValue<String>('database.password');
}
```

### Usage
```dart
await MayrConfig.load('config.yaml', '.env');

// Generated type-safe access (most common use case)
String name = Config.app.name;
String url = Config.api.baseUrl;
int timeout = Config.api.timeout;

// Dynamic access when needed
String name = MayrConfig.get('app.name');

// Extension syntax
String name = 'app.name'.config;
int timeout = 'api.timeout'.config<int>();
```

### Pros
- ✅ ✨ **Simplest possible runtime API**
- ✅ ✨ **Best generated code ergonomics** (Config.api.timeout)
- ✅ ✨ **Clear separation**: codegen for type safety, runtime for dynamic
- ✅ Easy to understand and maintain
- ✅ Small memory footprint
- ✅ Multiple access patterns (generated, dynamic, extension)

### Cons
- ❌ Less functional/immutable

---

## 🎨 Proposal 5: **Builder Pattern with Validation**

### Philosophy
Configuration as a built object with validation support.

### Architecture

```dart
class ConfigBuilder {
  String? _yamlPath;
  String? _envPath;
  final _validators = <ConfigValidator>[];
  
  ConfigBuilder yaml(String path) {
    _yamlPath = path;
    return this;
  }
  
  ConfigBuilder env(String path) {
    _envPath = path;
    return this;
  }
  
  ConfigBuilder validate(ConfigValidator validator) {
    _validators.add(validator);
    return this;
  }
  
  Future<LoadedConfig> build() async {
    // Load and validate
    final config = await _load();
    for (var validator in _validators) {
      validator.validate(config);
    }
    return config;
  }
}

class LoadedConfig {
  final Map<String, dynamic> _values;
  
  LoadedConfig._(this._values);
  
  T get<T>(String key, {T? defaultValue, bool required = false}) {
    if (required && !_values.containsKey(key)) {
      throw ConfigKeyRequired(key);
    }
    return (_values[key] ?? defaultValue) as T;
  }
}

// Validators
abstract class ConfigValidator {
  void validate(LoadedConfig config);
}

class RequiredKeysValidator extends ConfigValidator {
  final List<String> keys;
  RequiredKeysValidator(this.keys);
  
  @override
  void validate(LoadedConfig config) {
    for (var key in keys) {
      if (!config._values.containsKey(key)) {
        throw ConfigKeyMissing(key);
      }
    }
  }
}
```

### Usage
```dart
final config = await ConfigBuilder()
  .env('.env')
  .yaml('config.yaml')
  .validate(RequiredKeysValidator(['app.name', 'api.baseUrl']))
  .build();

String name = config.get<String>('app.name', required: true);
```

### Pros
- ✅ Built-in validation support
- ✅ Fluent API
- ✅ Explicit about requirements

### Cons
- ❌ More complex
- ❌ Overkill for simple use cases
- ❌ Code generation integration unclear

---

## 📊 Comparison Matrix

| Feature | Proposal 1 | Proposal 2 | Proposal 3 | **Proposal 4** | Proposal 5 |
|---------|-----------|-----------|-----------|--------------|-----------|
| **Simplicity** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Type Safety** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Generated Code Quality** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Runtime Flexibility** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Learning Curve** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Env Integration** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Maintainability** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🏆 Recommendation: **Proposal 4 - Minimal Core with Smart Codegen**

### Why Proposal 4?

1. **Simplest Runtime**: One class, straightforward methods
2. **Best DX**: `Config.api.timeout` reads beautifully
3. **Flexible**: Works for both static (generated) and dynamic use cases
4. **Maintainable**: Minimal code, clear responsibilities
5. **Type-Safe**: Compile-time safety through codegen, runtime safety through generics

### Migration Path from v1.0.0

The API would actually be simpler:

**Before (v1.0.0):**
```dart
await MayrConfig.load(yamlPath: 'config.yaml', envPath: '.env');
String name = MayrConfig.get('app.name');
```

**After (v2.0.0 - Proposal 4):**
```dart
await MayrConfig.load('config.yaml', '.env');
String name = Config.app.name; // Generated
// or
String name = MayrConfig.get('app.name'); // Dynamic
```

### Implementation Priority

1. **Phase 1**: Core MayrConfig class (single file, ~100 lines)
2. **Phase 2**: Env loading and interpolation (integrated into core)
3. **Phase 3**: Code generator for type-safe accessors
4. **Phase 4**: Extension methods for convenience

### File Structure (Simplified)

```
lib/
├── mayr_config.dart          # Main export
└── src/
    ├── config.dart           # Core MayrConfig class (everything!)
    ├── generator.dart        # Code generator
    └── exceptions.dart       # Custom exceptions
```

---

## Questions for Decision

1. Do you prefer the nested object style (`Config.api.timeout`) or flat extensions (`ApiConfig.timeout`)?
2. Should we support validation in v2.0, or keep it for a future version?
3. Is hot-reload important for your use cases?
4. Do you need to support multiple config files (e.g., `config/app.yaml`, `config/api.yaml`)?

---

## Alternative Considerations

If you want something different from Proposal 4, here's what I'd recommend:

- **Need advanced features** (validation, watchers, multiple files) → Proposal 5
- **Want functional/immutable style** → Proposal 3
- **Prefer clear layer separation** → Proposal 2
- **Want explicit typing everywhere** → Proposal 1

Let me know which proposal resonates with you, or if you want to mix elements from different proposals!
