# MayrConfig Examples

This directory contains various examples demonstrating different features of MayrConfig v1.0.0.

## Quick Start

1. **Install dependencies** (if running from this directory):
   ```bash
   dart pub get
   ```

2. **Run an example**:
   ```bash
   dart run simple_example.dart
   ```

## Example Files

### Basic Examples

- **`simple_example.dart`** - Simplest usage with single config file
  - Shows basic loading and access
  - Good starting point for beginners

- **`mayr_config_example.dart`** - Main example with multiple config files
  - Demonstrates loading from `config/` directory
  - Shows type-safe access with `getValue<T>()`
  - Environment variable usage
  - String extensions
  - Validation

- **`complete_example.dart`** - Comprehensive feature showcase
  - All MayrConfig features demonstrated
  - Type-safe access
  - Validation
  - Error handling
  - Best practices

### Advanced Examples

- **`generated_example.dart`** - Code generation demonstration
  - Shows how to use generated type-safe accessors
  - Requires running `dart run build_runner build` first
  - Demonstrates the nested structure syntax

## Configuration Files

### Single File Setup

- **`config.yaml`** - Single configuration file
  - Contains all configuration in one file
  - Good for simple projects

### Multiple Files Setup (Recommended)

- **`config/app.yaml`** - Application settings
- **`config/api.yaml`** - API configuration
- **`config/database.yaml`** - Database settings
- **`.env`** - Environment variables (secrets)

## Running Examples

### Simple Example (Single File)
```bash
dart run simple_example.dart
```

### Main Example (Multiple Files)
```bash
dart run mayr_config_example.dart
```

### Complete Example (All Features)
```bash
dart run complete_example.dart
```

### Generated Example (Type-Safe Code)
```bash
# First, generate the code
dart run build_runner build

# Then run the example
dart run generated_example.dart
```

## Features Demonstrated

### 1. Loading Configuration
- Single file: `MayrConfig.load('config.yaml', '.env')`
- Multiple files: `MayrConfig.load(['config/app.yaml', 'config/api.yaml'], '.env')`

### 2. Accessing Values
- Dynamic: `MayrConfig.get('app.name')`
- Type-safe: `MayrConfig.getValue<String>('app.name')`
- Extension: `'app.name'.config`
- Type-safe extension: `'app.name'.configValue<String>()`

### 3. Environment Variables
- In YAML: `baseUrl: ${API_URL}`
- Direct access: `MayrConfig.env('API_URL')`

### 4. Validation
```dart
MayrConfig.addValidator(
  RequiredKeysValidator(['app.name', 'api.baseUrl']),
);
```

### 5. Type Safety
```dart
final timeout = MayrConfig.getValue<int>('api.timeout'); // int
final debug = MayrConfig.getValue<bool>('app.debug');     // bool
```

### 6. Generated Code (After build_runner)
```dart
final name = App.app.name;        // String
final url = Api.api.baseUrl;      // String
final timeout = Api.api.timeout;  // int
```

## Tips

1. **Start with `simple_example.dart`** to understand the basics
2. **Use multiple config files** for better organization (see `config/` directory)
3. **Add validation** to catch configuration errors early
4. **Run code generation** for the best type safety and DX:
   ```bash
   dart run build_runner build
   ```
5. **Keep secrets in `.env`** files (don't commit them!)

## Common Issues

### "Config file not found"
Make sure you're running from the correct directory or use absolute paths.

### "Environment variable not found"
Check that your `.env` file exists and contains the required variables.

### Generated files not working
Run `dart run build_runner build` to generate the type-safe accessor files.

## More Information

- **README.md** (root) - Complete API reference
- **DESIGN.md** - Architecture overview
- **test/** - Unit tests showing more usage patterns
