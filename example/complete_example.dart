import 'package:mayr_config/mayr_config.dart';

/// Comprehensive example showcasing all MayrConfig features.
///
/// This example demonstrates:
/// - Loading YAML configuration with .env interpolation
/// - Accessing values using different methods
/// - Type handling for different data types
/// - Configuration utilities (has, keys, reload)
/// - Best practices for using MayrConfig
Future<void> main() async {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║        MayrConfig - Complete Feature Showcase            ║');
  print('╚═══════════════════════════════════════════════════════════╝\n');

  // ═══════════════════════════════════════════════════════════════
  // 1. Load Configuration
  // ═══════════════════════════════════════════════════════════════
  print('📂 Loading configuration...\n');

  await MayrConfig.loadFromYaml('example/config.yaml', 'example/.env');
  print('✓ Configuration loaded successfully!\n');

  // ═══════════════════════════════════════════════════════════════
  // 2. Basic Value Access
  // ═══════════════════════════════════════════════════════════════
  print('🔍 Basic Value Access:');
  print('─────────────────────────────────────────────────────────');
  print('  App Name:    ${MayrConfig.get('app.name')}');
  print('  Environment: ${MayrConfig.get('app.env')}');
  print('  Debug Mode:  ${MayrConfig.get('app.debug')}');
  print('  Locale:      ${MayrConfig.get('app.locale')}\n');

  // ═══════════════════════════════════════════════════════════════
  // 3. Environment Variable Interpolation
  // ═══════════════════════════════════════════════════════════════
  print('🌍 Environment Variables (from .env file):');
  print('─────────────────────────────────────────────────────────');
  print('  API URL:      ${MayrConfig.get('api.baseUrl')}');
  print('  DB Password:  ${MayrConfig.get('database.password')}\n');

  // ═══════════════════════════════════════════════════════════════
  // 4. String Extension Syntax
  // ═══════════════════════════════════════════════════════════════
  print('✨ Using String Extension (.mayrConfig()):');
  print('─────────────────────────────────────────────────────────');
  print('  API Timeout:  ${'api.timeout'.mayrConfig()} ms');
  print('  DB Host:      ${'database.host'.mayrConfig()}');
  print('  DB Port:      ${'database.port'.mayrConfig()}\n');

  // ═══════════════════════════════════════════════════════════════
  // 5. Type Handling
  // ═══════════════════════════════════════════════════════════════
  print('🎯 Type Handling:');
  print('─────────────────────────────────────────────────────────');

  final appName = MayrConfig.get('app.name'); // String
  final debug = MayrConfig.get('app.debug'); // bool
  final timeout = MayrConfig.get('api.timeout'); // int

  print('  String:  $appName (${appName.runtimeType})');
  print('  Boolean: $debug (${debug.runtimeType})');
  print('  Integer: $timeout (${timeout.runtimeType})\n');

  // ═══════════════════════════════════════════════════════════════
  // 6. Default Values
  // ═══════════════════════════════════════════════════════════════
  print('🛡️  Default Values (for missing keys):');
  print('─────────────────────────────────────────────────────────');
  print('  Missing key 1: ${MayrConfig.get('nonexistent.key', 'fallback')}');
  print('  Missing key 2: ${'another.missing'.mayrConfig(999)}\n');

  // ═══════════════════════════════════════════════════════════════
  // 7. Configuration Utilities
  // ═══════════════════════════════════════════════════════════════
  print('🔧 Configuration Utilities:');
  print('─────────────────────────────────────────────────────────');

  // Check if keys exist
  print('  Has "app.name"?       ${MayrConfig.has('app.name')}');
  print('  Has "missing.key"?    ${MayrConfig.has('missing.key')}');

  // Get all keys
  final keyCount = MayrConfig.keys().length;
  print('  Total config keys:    $keyCount');

  // List all keys
  print('\n  All available keys:');
  for (var key in MayrConfig.keys()) {
    print('    • $key');
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. Dynamic Reload
  // ═══════════════════════════════════════════════════════════════
  print('🔄 Dynamic Reload:');
  print('─────────────────────────────────────────────────────────');
  print('  Current app.name: ${MayrConfig.get('app.name')}');

  await MayrConfig.reload();
  print('  ✓ Configuration reloaded');
  print('  After reload:     ${MayrConfig.get('app.name')}\n');

  // ═══════════════════════════════════════════════════════════════
  // 9. Best Practices
  // ═══════════════════════════════════════════════════════════════
  print('💡 Best Practices:');
  print('─────────────────────────────────────────────────────────');
  print('  1. Always use default values for optional configs');
  print('  2. Check key existence before accessing in critical paths');
  print('  3. Use .mayrConfig() for cleaner code');
  print('  4. Generate type-safe accessors with:');
  print('     dart run build_runner build');
  print('  5. Keep sensitive data in .env files');
  print('  6. Use reload() for hot-reloading during development\n');

  // ═══════════════════════════════════════════════════════════════
  // 10. Summary
  // ═══════════════════════════════════════════════════════════════
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║                    Summary                                ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║  ✓ Configuration loaded and parsed                        ║');
  print('║  ✓ Environment variables interpolated                     ║');
  print('║  ✓ All access methods working                             ║');
  print('║  ✓ Type safety maintained                                 ║');
  print('║  ✓ Utilities functional                                   ║');
  print('╚═══════════════════════════════════════════════════════════╝\n');

  print('🎉 All features demonstrated successfully!\n');
  print('For more information, visit:');
  print('  📖 README.md - Usage guide');
  print('  🏗️  DESIGN.md - Architecture details');
  print('  🧪 test/ - Test examples');
  print('  💻 example/ - More code examples');
}
