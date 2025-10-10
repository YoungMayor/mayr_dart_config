## 1.0.0

### 🎉 Initial Release

A flexible, type-safe, and environment-aware configuration system for Dart and Flutter apps.

#### Features

- ✅ **YAML Configuration**: Load configuration from `config.yaml` files
- ✅ **Environment Variables**: Support for `.env` files with `${VAR}` interpolation in YAML
- ✅ **Dot Notation Access**: Intuitive `MayrConfig.get('api.baseUrl')` syntax
- ✅ **String Extension**: Convenient `'api.baseUrl'.mayrConfig()` shorthand
- ✅ **Type-Safe Generation**: Generate typed accessors with `dart run build_runner build`
- ✅ **Hot Reloadable**: Reload configuration at runtime with `MayrConfig.reload()`
- ✅ **Cross-Platform**: Works in both Dart and Flutter applications

#### Core Components

- `MayrConfigCore`: Singleton storage and access layer
- `MayrConfig`: Public API for loading and accessing configuration
- `MayrEnv`: Environment variable loader for `.env` files
- `MayrConfigStringExt`: String extension for convenient access
- `MayrConfigGenerator`: build_runner-based code generator for type-safe configuration classes

#### API Methods

- `MayrConfig.load()`: Load both YAML and .env files
- `MayrConfig.loadFromYaml()`: Load configuration from YAML
- `MayrConfig.get(key, [default])`: Get configuration value
- `MayrConfig.has(key)`: Check if key exists
- `MayrConfig.keys()`: Get all configuration keys
- `MayrConfig.reload()`: Reload configuration at runtime
- `MayrConfig.clear()`: Clear all configuration (useful for testing)

#### Engineering Principles

- **DRY (Don't Repeat Yourself)**: Centralized configuration management
- **SRP (Single Responsibility Principle)**: Each component has a focused purpose
- **KISS (Keep It Simple, Stupid)**: Clean, intuitive API
- **Modularization**: Well-organized into separate modules

#### Documentation

- Comprehensive inline documentation
- Working examples with config.yaml and .env
- 23 unit tests covering all functionality
- README with usage instructions and examples
- DESIGN.md with architecture details
