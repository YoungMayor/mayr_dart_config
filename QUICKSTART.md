# MayrConfig Quick Start Guide

Get up and running with MayrConfig in 5 minutes!

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  mayr_config: ^1.0.0
```

Then run:
```bash
dart pub get
```

## Quick Setup

### 1. Create your configuration file

Create `config.yaml` in your project root:

```yaml
app:
  name: MyAwesomeApp
  version: 1.0.0
  debug: true

api:
  baseUrl: ${API_URL}
  timeout: 5000

database:
  host: localhost
  port: 5432
```

### 2. Create environment file (optional)

Create `.env` in your project root:

```env
API_URL=https://api.example.com
DB_PASSWORD=secret123
```

### 3. Load and use in your code

```dart
import 'package:mayr_config/mayr_config.dart';

Future<void> main() async {
  // Load configuration
  await MayrConfig.loadFromYaml('config.yaml');

  // Access values
  print(MayrConfig.get('app.name'));
  print('api.baseUrl'.mayrConfig());
}
```

## Generate Type-Safe Accessors (Optional)

For better IDE support and type safety:

```bash
dart run build_runner build
```

> **Note**: The generator looks for `config.yaml` in your project root. Make sure it exists before running the generator.

This creates `lib/config.g.dart`:

```dart
class AppConfig {
  static String get name => MayrConfig.get('app.name');
  static String get version => MayrConfig.get('app.version');
  static bool get debug => MayrConfig.get('app.debug');
}
```

Use it:

```dart
import 'package:mayr_config/config.g.dart';

print(AppConfig.name);        // Type-safe!
print(AppConfig.version);     // Autocomplete!
```

## Common Patterns

### With Default Values
```dart
final timeout = MayrConfig.get('api.timeout', 3000);
final retries = 'api.retries'.mayrConfig(3);
```

### Check Before Access
```dart
if (MayrConfig.has('feature.enabled')) {
  final enabled = MayrConfig.get('feature.enabled');
}
```

### Reload at Runtime
```dart
await MayrConfig.reload();  // Re-read files
```

## Next Steps

- Check out the [examples](example/) directory
- Read the [README.md](README.md) for full documentation
- See [DESIGN.md](DESIGN.md) for architecture details
- Run the examples: `dart run example/complete_example.dart`

## Tips

✅ **DO**: Use environment variables for secrets  
✅ **DO**: Generate type-safe accessors for large configs  
✅ **DO**: Provide default values for optional settings  

❌ **DON'T**: Commit `.env` files to version control  
❌ **DON'T**: Store passwords directly in `config.yaml`  

## Need Help?

- 📖 Read the [full documentation](README.md)
- 🐛 [Report issues](https://github.com/YoungMayor/mayr_dart_config/issues)
- 💬 [Ask questions](https://github.com/YoungMayor/mayr_dart_config/discussions)

Happy configuring! 🚀
