import 'package:mayr_config/mayr_config.dart';

/// Comprehensive example showcasing all MayrConfig v1.0.0 features.
///
/// This example demonstrates:
/// - Loading YAML configuration with .env interpolation
/// - Accessing values using different methods (getValue<T>, .config, .configValue<T>())
/// - Type handling for different data types
/// - Configuration utilities (has, keys, env)
/// - Validation
/// - Best practices for using MayrConfig
Future<void> main() async {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║        MayrConfig v1.0.0 - Complete Feature Showcase     ║');
  print('╚═══════════════════════════════════════════════════════════╝\n');

  // ═══════════════════════════════════════════════════════════════
  // 1. Load Configuration with Validation
  // ═══════════════════════════════════════════════════════════════
  print('📂 Loading configuration with validation...\n');

  // Add validators before loading
  MayrConfig.addValidator(
    RequiredKeysValidator(['app.name', 'api.baseUrl']),
  );

  MayrConfig.addValidator(
    TypeValidator({
      'app.name': String,
      'app.debug': bool,
      'api.timeout': int,
    }),
  );

  await MayrConfig.load([
    'example/config/app.yaml',
    'example/config/api.yaml',
    'example/config/database.yaml',
  ], 'example/.env');

  print('✓ Configuration loaded successfully!');
  print('✓ All validators passed!\n');

  // ═══════════════════════════════════════════════════════════════
  // 2. Basic Value Access
  // ═══════════════════════════════════════════════════════════════
  print('🔍 Basic Value Access (dynamic):');
  print('─────────────────────────────────────────────────────────');
  print('  App Name:      ${MayrConfig.get('app.name')}');
  print('  Environment:   ${MayrConfig.get('app.environment')}');
  print('  Debug Mode:    ${MayrConfig.get('app.debug')}');
  print('  App Version:   ${MayrConfig.get('app.version')}\n');

  // ═══════════════════════════════════════════════════════════════
  // 3. Type-Safe Access with getValue<T>()
  // ═══════════════════════════════════════════════════════════════
  print('🎯 Type-Safe Access with getValue<T>():');
  print('─────────────────────────────────────────────────────────');

  final appName = MayrConfig.getValue<String>('app.name');
  final debug = MayrConfig.getValue<bool>('app.debug');
  final timeout = MayrConfig.getValue<int>('api.timeout');
  final dbPort = MayrConfig.getValue<int>('database.port');

  print('  String:  $appName (type: ${appName.runtimeType})');
  print('  Boolean: $debug (type: ${debug.runtimeType})');
  print('  Integer: $timeout (type: ${timeout.runtimeType})');
  print('  Integer: $dbPort (type: ${dbPort.runtimeType})\n');

  // ═══════════════════════════════════════════════════════════════
  // 4. Environment Variable Interpolation
  // ═══════════════════════════════════════════════════════════════
  print('🌍 Environment Variables (from .env file):');
  print('─────────────────────────────────────────────────────────');
  print('  API URL:       ${MayrConfig.get('api.baseUrl')}');
  print('  DB Password:   ${MayrConfig.get('database.password')}');
  print('  App Env:       ${MayrConfig.get('app.environment')}\n');

  // Direct environment access
  print('  Direct env access:');
  print('  - APP_ENV:      ${MayrConfig.env('APP_ENV')}');
  print('  - API_URL:      ${MayrConfig.env('API_URL')}');
  print('  - DB_PASSWORD:  ${MayrConfig.env('DB_PASSWORD')}\n');

  // ═══════════════════════════════════════════════════════════════
  // 5. String Extension Syntax
  // ═══════════════════════════════════════════════════════════════
  print('✨ Using String Extension (.config and .configValue<T>()):');
  print('─────────────────────────────────────────────────────────');
  print('  API Timeout (dynamic):  ${'api.timeout'.config} ms');
  print('  API Timeout (typed):    ${'api.timeout'.configValue<int>()} ms');
  print('  DB Host:                ${'database.host'.config}');
  print('  DB Username:            ${'database.username'.config}\n');

  // ═══════════════════════════════════════════════════════════════
  // 6. Default Values
  // ═══════════════════════════════════════════════════════════════
  print('🛡️  Default Values (for missing keys):');
  print('─────────────────────────────────────────────────────────');
  print('  Missing key 1: ${MayrConfig.get('nonexistent.key', 'fallback')}');
  print('  Missing key 2: ${MayrConfig.get('another.missing', 999)}\n');

  // ═══════════════════════════════════════════════════════════════
  // 7. Configuration Utilities
  // ═══════════════════════════════════════════════════════════════
  print('🔧 Configuration Utilities:');
  print('─────────────────────────────────────────────────────────');

  // Check if keys exist
  print('  Has "app.name"?          ${MayrConfig.has('app.name')}');
  print('  Has "missing.key"?       ${MayrConfig.has('missing.key')}');

  // Get all keys
  final keyCount = MayrConfig.keys().length;
  print('  Total config keys:       $keyCount');

  // List all keys
  print('\n  All available keys:');
  for (var key in MayrConfig.keys()) {
    print('    • $key');
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. Error Handling Demo
  // ═══════════════════════════════════════════════════════════════
  print('\n🚦 Error Handling:');
  print('─────────────────────────────────────────────────────────');

  try {
    // This will throw ConfigTypeMismatch
    MayrConfig.getValue<int>('app.name'); // name is String, not int
  } catch (e) {
    print('  ✓ ConfigTypeMismatch caught: $e');
  }

  try {
    // This will throw ConfigKeyNotFound
    MayrConfig.getValue<String>('nonexistent.key');
  } catch (e) {
    print('  ✓ ConfigKeyNotFound caught: $e');
  }

  // ═══════════════════════════════════════════════════════════════
  // 9. Best Practices
  // ═══════════════════════════════════════════════════════════════
  print('\n💡 Best Practices:');
  print('─────────────────────────────────────────────────────────');
  print('  1. Add validators before loading config');
  print('  2. Use getValue<T>() for type-safe access');
  print('  3. Always use default values for optional configs');
  print('  4. Check key existence before accessing in critical paths');
  print('  5. Use .config or .configValue<T>() for cleaner code');
  print('  6. Generate type-safe accessors with:');
  print('     dart run build_runner build');
  print('  7. Keep sensitive data in .env files');
  print('  8. Organize configs by feature in config/ directory\n');

  // ═══════════════════════════════════════════════════════════════
  // 10. Summary
  // ═══════════════════════════════════════════════════════════════
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║                    Summary                                ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║  ✓ Configuration loaded from multiple files               ║');
  print('║  ✓ Environment variables interpolated                     ║');
  print('║  ✓ Validation passed successfully                         ║');
  print('║  ✓ All access methods working (get, getValue, extensions) ║');
  print('║  ✓ Type safety demonstrated                               ║');
  print('║  ✓ Error handling working correctly                       ║');
  print('║  ✓ Utilities functional                                   ║');
  print('╚═══════════════════════════════════════════════════════════╝\n');

  print('🎉 All features demonstrated successfully!\n');
  print('For more information, visit:');
  print('  📖 README.md - Complete usage guide');
  print('  🏗️  DESIGN.md - Architecture details');
  print('  🧪 test/ - Test examples');
  print('  💻 example/ - More code examples');
}
