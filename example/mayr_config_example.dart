import 'package:mayr_config/mayr_config.dart';

/// Example demonstrating MayrConfig v1.0.0 usage with Proposal 4 architecture.
///
/// This example shows how to:
/// - Load configuration from multiple YAML files in config/ directory
/// - Use environment variables with .env files
/// - Access values with type-safe methods
/// - Use validation
/// - Work with the new unified API
Future<void> main() async {
  print('=== MayrConfig v1.0.0 Example ===\n');

  // Add validators before loading (optional but recommended)
  MayrConfig.addValidator(
    RequiredKeysValidator(['app.name', 'api.baseUrl']),
  );

  print('--- Loading Multiple Config Files ---');
  // Load configuration from multiple YAML files
  await MayrConfig.load([
    'example/config/app.yaml',
    'example/config/api.yaml',
    'example/config/database.yaml',
  ], 'example/.env');

  print('✅ Configuration loaded successfully!\n');

  print('--- Basic Dynamic Access ---');
  // Access configuration using MayrConfig.get()
  print('App Name: ${MayrConfig.get('app.name')}');
  print('App Environment: ${MayrConfig.get('app.environment')}');
  print('Debug Mode: ${MayrConfig.get('app.debug')}');
  print('App Version: ${MayrConfig.get('app.version')}');

  print('\n--- Type-Safe Access with getValue<T>() ---');
  // Use getValue<T>() for type-safe access
  final appName = MayrConfig.getValue<String>('app.name');
  final timeout = MayrConfig.getValue<int>('api.timeout');
  final debug = MayrConfig.getValue<bool>('app.debug');
  final dbPort = MayrConfig.getValue<int>('database.port');

  print('App Name (String): $appName');
  print('API Timeout (int): $timeout ms');
  print('Debug Mode (bool): $debug');
  print('Database Port (int): $dbPort');

  print('\n--- Environment Variable Interpolation ---');
  // These values come from environment variables
  print('API Base URL: ${MayrConfig.get('api.baseUrl')}');
  print('Database Password: ${MayrConfig.get('database.password')}');

  print('\n--- Direct Environment Access ---');
  print('APP_ENV: ${MayrConfig.env('APP_ENV')}');
  print('API_URL: ${MayrConfig.env('API_URL')}');
  print('DB_PASSWORD: ${MayrConfig.env('DB_PASSWORD')}');

  print('\n--- Using String Extension ---');
  // Access configuration using the convenient .config extension
  print('API Timeout: ${'api.timeout'.config}');
  print('Database Host: ${'database.host'.config}');
  print('Database Username: ${'database.username'.config}');

  // Type-safe extension method
  print('Database Pool Size (int): ${'database.poolSize'.configValue<int>()}');

  print('\n--- Default Values ---');
  // Provide default values for missing keys
  print('Missing Key: ${MayrConfig.get('missing.key', 'default-value')}');

  print('\n--- Configuration Utilities ---');
  // Check if a key exists
  print('Has app.name? ${MayrConfig.has('app.name')}');
  print('Has missing.key? ${MayrConfig.has('missing.key')}');

  // Get all configuration keys
  print('\nAll Configuration Keys (${MayrConfig.keys().length} total):');
  for (var key in MayrConfig.keys().take(10)) {
    print('  - $key: ${MayrConfig.get(key)}');
  }
  if (MayrConfig.keys().length > 10) {
    print('  ... and ${MayrConfig.keys().length - 10} more');
  }

  print('\n--- Type Safety Demo ---');
  try {
    // This will throw ConfigTypeMismatch because 'app.name' is a String
    MayrConfig.getValue<int>('app.name');
  } catch (e) {
    print('✅ Type mismatch caught: ${e.runtimeType}');
  }

  try {
    // This will throw ConfigKeyNotFound
    MayrConfig.getValue<String>('nonexistent.key');
  } catch (e) {
    print('✅ Missing key caught: ${e.runtimeType}');
  }

  print('\n--- Validation Demo ---');
  print('✅ All validators passed during load!');
  print('   Required keys validated: app.name, api.baseUrl');

  print('\n=== Example Complete ===');
  print('\n💡 Next Steps:');
  print('   1. Run: dart run build_runner build');
  print('   2. Import generated files: config/app.g.dart, config/api.g.dart');
  print('   3. Use type-safe nested syntax: App.app.name, Api.api.baseUrl');
}
