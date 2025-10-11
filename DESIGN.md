# 🧩 DESIGN.md — MayrConfig v1.0.0

## Overview

**MayrConfig** provides a clean, type-safe, and environment-aware configuration system for Dart and Flutter apps.

The v1.0.0 implementation uses the **Minimal Core with Smart Codegen** architecture (Proposal 4), chosen for its simplicity, excellent developer experience, and maintainability.

---

## 🎯 Design Philosophy

### Core Principles

1. **Simplicity** - One unified class handles everything (no scattered concerns)
2. **Type Safety** - Compile-time safety through codegen + runtime type checking
3. **Clean API** - Intuitive methods, clear naming, minimal learning curve
4. **Flexibility** - Support multiple config files, validation, and access patterns

### Why "Minimal Core with Smart Codegen"?

- ✨ **Single source of truth** - `MayrConfig` class handles all runtime operations
- 🎯 **Best DX** - Beautiful nested syntax: `Config.api.timeout`
- 📦 **Smallest codebase** - Easier to maintain and extend
- 🔒 **Type-safe by default** - Through smart code generation
- ⚡ **Better performance** - Fewer indirections, cleaner code paths

---

## ⚙️ Architecture

### Component Overview

```
┌─────────────────────────────────────────────────┐
│           User Code / Application               │
└─────┬───────────────────────────┬───────────────┘
      │                           │
      │ Type-Safe (Generated)     │ Dynamic (Runtime)
      │                           │
      ▼                           ▼
┌─────────────┐          ┌──────────────┐
│   Config    │          │  MayrConfig  │
│  .api       │          │   .get()     │
│  .timeout   │          │   .getValue()│
└─────┬───────┘          └──────┬───────┘
      │                         │
      └────────────┬────────────┘
                   │
                   ▼
          ┌────────────────┐
          │  MayrConfig    │
          │  (Core Class)  │
          │                │
          │  • Env loading │
          │  • YAML parse  │
          │  • Interpolate │
          │  • Validation  │
          │  • Type check  │
          └────────────────┘
```

### File Structure

```
lib/
├── mayr_config.dart           # Main export file
└── src/
    ├── core.dart              # Unified MayrConfig class (~350 lines)
    ├── exceptions.dart        # Custom exceptions
    ├── extension.dart         # String extensions
    └── generator.dart         # Code generator
```

**Total: ~600 lines** (vs 545 in old architecture)
- But: Single responsibility, no overlap, clearer code
- Old: 5 classes, scattered concerns
- New: 3 classes, clear responsibilities

---

## 🧩 Core Classes

### `MayrConfig` (Unified Core)

The single source of truth for all configuration operations.

**Responsibilities:**
- Load environment variables from `.env` files
- Parse YAML configuration files (single or multiple)
- Interpolate `${VAR}` syntax with env values
- Flatten nested maps into dot notation
- Provide type-safe `getValue<T>()` method
- Run validators on load
- Store and retrieve configuration values

**Key Methods:**

```dart
class MayrConfig {
  // Loading
  static Future<void> load(dynamic configPath, [dynamic envPath]);
  
  // Dynamic access
  static dynamic get(String key, [dynamic defaultValue]);
  
  // Type-safe access
  static T getValue<T>(String key);
  
  // Environment variables
  static String? env(String key);
  static Map<String, String> get allEnv;
  
  // Utilities
  static bool has(String key);
  static Iterable<String> keys();
  static Map<String, dynamic> get all;
  
  // Validation
  static void addValidator(ConfigValidator validator);
  static void clearValidators();
  
  // Cleanup
  static void clear();
}
```

---

## 📖 Complete Documentation

For complete design documentation, see:
- **README.md** - API reference and usage guide
- **DESIGN_PROPOSALS_V2.md** - All 5 design options considered
- **ARCHITECTURE_COMPARISON.md** - Detailed comparison of v1.0 vs Proposal 4
- **EXAMPLE_USAGE.md** - Real-world usage examples

---

**Design Version**: 1.0.0  
**Last Updated**: 2025-10-11  
**Status**: Implemented ✅
