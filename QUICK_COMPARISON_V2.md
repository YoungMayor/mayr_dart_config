# MayrConfig v2.0 - Quick Visual Comparison

## 🎯 Your Priority: Type Safety + Env Support + Clean API

---

## Side-by-Side Usage Comparison

### Current v1.0.0
```dart
// Loading
await MayrConfig.load(yamlPath: 'config.yaml', envPath: '.env');

// Access (all dynamic, no type safety)
final name = MayrConfig.get('app.name');           // dynamic
final url = MayrConfig.get('api.baseUrl');         // dynamic
final timeout = MayrConfig.get('api.timeout');     // dynamic

// Extension sugar
final port = 'database.port'.mayrConfig();         // dynamic

// Generated (current approach)
print(AppConfig.name);    // Calls MayrConfig.get internally
print(ApiConfig.baseUrl); // Calls MayrConfig.get internally
```

### ✨ Proposal 4 (RECOMMENDED)
```dart
// Loading (simpler)
await MayrConfig.load('config.yaml', '.env');

// Generated type-safe access (BEST DX)
final name = Config.app.name;         // String ✅
final url = Config.api.baseUrl;       // String ✅
final timeout = Config.api.timeout;   // int ✅
final port = Config.database.port;    // int ✅

// Dynamic when needed
final name = MayrConfig.get('app.name');              // dynamic
final timeout = MayrConfig.getValue<int>('api.timeout'); // int

// Extension sugar
final name = 'app.name'.config;           // dynamic
final timeout = 'api.timeout'.config<int>(); // int
```

### Proposal 1
```dart
await config.load(yaml: 'config.yaml', env: '.env');

// Explicit type methods
final name = config.getString('app.name');
final timeout = config.getInt('api.timeout');
final debug = config.getBool('app.debug');

// Generated
final name = Config.appName;    // String
final url = Config.apiBaseUrl;  // String (flat structure)
```

### Proposal 2
```dart
await Config.init(configPath: 'config.yaml', envPath: '.env');

// Extensions
final name = AppConfig.name;       // String
final url = ApiConfig.baseUrl;     // String
final timeout = ApiConfig.timeout; // int

// Dynamic
final name = Config.get<String>('app.name');
```

### Proposal 3
```dart
final config = await AppConfig.load(yaml: 'config.yaml', env: '.env');
final gen = GeneratedConfig(config);

// Nested objects
final name = gen.appName;         // String
final url = gen.api.baseUrl;      // String
final timeout = gen.api.timeout;  // int

// Functional style
final name = config.get<String>('app.name').value;
final timeout = config.get<int>('api.timeout').or(5000);
```

### Proposal 5
```dart
final config = await ConfigBuilder()
  .env('.env')
  .yaml('config.yaml')
  .validate(RequiredKeysValidator(['app.name']))
  .build();

final name = config.get<String>('app.name', required: true);
```

---

## 🏗️ Architecture Comparison

### Current v1.0.0
```
lib/src/
├── core.dart          - MayrConfigCore singleton
├── loader.dart        - MayrConfig public API
├── env.dart           - MayrEnv (separate)
├── extension.dart     - String extension
└── generator.dart     - Code generator
```
**5 files, overlapping responsibilities**

### Proposal 4 (RECOMMENDED)
```
lib/src/
├── config.dart        - MayrConfig (ALL runtime logic)
├── generator.dart     - Code generator
└── exceptions.dart    - Custom exceptions
```
**3 files, clear responsibilities**

### Others
- **Proposal 1**: 2-3 files (simple)
- **Proposal 2**: 3-4 files (layered)
- **Proposal 3**: 3-4 files (functional)
- **Proposal 5**: 4-5 files (feature-rich)

---

## 📝 Generated Code Comparison

Given this `config.yaml`:
```yaml
app:
  name: MyApp
  debug: true
  
api:
  baseUrl: ${API_URL}
  timeout: 5000
```

### Proposal 4 Output (Best DX)
```dart
class Config {
  Config._();
  
  static final app = _App();
  static final api = _Api();
}

class _App {
  String get name => MayrConfig.getValue<String>('app.name');
  bool get debug => MayrConfig.getValue<bool>('app.debug');
}

class _Api {
  String get baseUrl => MayrConfig.getValue<String>('api.baseUrl');
  int get timeout => MayrConfig.getValue<int>('api.timeout');
}

// Usage: Config.api.timeout ✨
```

### Proposal 1 Output
```dart
class Config {
  static String get appName => config.getString('app.name');
  static bool get appDebug => config.getBool('app.debug');
  static String get apiBaseUrl => config.getString('api.baseUrl');
  static int get apiTimeout => config.getInt('api.timeout');
}

// Usage: Config.apiTimeout (flat)
```

### Proposal 2 Output
```dart
extension AppConfig on Config {
  static String get name => Config.get<String>('app.name')!;
  static bool get debug => Config.get<bool>('app.debug') ?? false;
}

extension ApiConfig on Config {
  static String get baseUrl => Config.get<String>('api.baseUrl')!;
  static int get timeout => Config.get<int>('api.timeout') ?? 5000;
}

// Usage: AppConfig.name, ApiConfig.timeout
```

### Proposal 3 Output
```dart
class GeneratedConfig {
  final AppConfig _config;
  
  String get appName => _config.get<String>('app.name').value;
  bool get appDebug => _config.get<bool>('app.debug').value;
  
  Api get api => Api(_config);
}

class Api {
  String get baseUrl => _config.get<String>('api.baseUrl').value;
  int get timeout => _config.get<int>('api.timeout').value;
}

// Usage: gen.api.timeout (need to pass config instance)
```

---

## 🎖️ Winner by Category

| Category | Winner | Runner-up |
|----------|--------|-----------|
| **Simplicity** | **Proposal 4** 🥇 | Proposal 1 🥈 |
| **Type Safety** | **Proposal 4** 🥇 | Proposal 3 🥈 |
| **DX (Developer Experience)** | **Proposal 4** 🥇 | Proposal 3 🥈 |
| **Generated Code Quality** | **Proposal 4** 🥇 | Proposal 3 🥈 |
| **Maintainability** | **Proposal 4** 🥇 | Proposal 1 🥈 |
| **Learning Curve** | **Proposal 4** 🥇 | Proposal 1 🥈 |
| **Advanced Features** | Proposal 5 🥇 | **Proposal 4** 🥈 |
| **Functional Purity** | Proposal 3 🥇 | Proposal 2 🥈 |

---

## 💡 Decision Helper

### Choose Proposal 4 if you want:
- ✅ Simplest possible API
- ✅ Best code completion (`Config.api.timeout`)
- ✅ Minimal learning curve
- ✅ Easy maintenance
- ✅ **This is the sweet spot for 90% of use cases**

### Choose Proposal 1 if you want:
- Explicit type methods (getString, getInt)
- Flat namespace for generated code
- Very simple, no magic

### Choose Proposal 2 if you want:
- Clear layer separation
- Extension-based generated code
- More testable architecture

### Choose Proposal 3 if you want:
- Immutable, functional approach
- Maybe monad for error handling
- Best for FP enthusiasts

### Choose Proposal 5 if you want:
- Built-in validation
- Builder pattern
- Advanced features out of the box

---

## 🚀 Next Steps

1. **Choose a proposal** (or mix elements)
2. **Answer these questions**:
   - Nested objects (`Config.api.timeout`) or flat (`ApiConfig.timeout`)?
   - Validation needed in v2.0?
   - Hot-reload important?
   - Multiple config files needed?

3. **I'll implement** the chosen design with:
   - Clean, minimal code
   - Full test coverage
   - Updated documentation
   - Migration guide

---

## My Recommendation

Go with **Proposal 4**. Here's why:

```dart
// What you'll write (beautiful!)
await MayrConfig.load('config.yaml', '.env');

final appName = Config.app.name;        // Perfect autocomplete
final apiUrl = Config.api.baseUrl;      // Type-safe
final timeout = Config.api.timeout;     // Clean hierarchy

// Still supports dynamic when needed
final anything = MayrConfig.get('any.key');
```

- **Least code to maintain** (one core class)
- **Best developer experience** (nested object syntax)
- **Backwards compatible** (can still use MayrConfig.get)
- **Type-safe by default** (through code generation)
- **Simple to understand** (no exotic patterns)

This is the design that will make your users smile! 😊
