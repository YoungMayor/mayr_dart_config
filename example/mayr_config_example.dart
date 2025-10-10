import 'package:mayr_config/mayr_config.dart';

/// Example demonstrating MayrConfig usage.
///
/// This example shows how to load configuration from YAML and .env files,
/// access values using different methods, and work with environment variables.
Future<void> main() async {
  print('=== MayrConfig Example ===\n');

  // Load configuration from YAML file (also loads .env automatically)
  await MayrConfig.loadFromYaml('example/config.yaml', 'example/.env');

  print('--- Basic Access ---');
  // Access configuration using MayrConfig.get()
  print('App Name: ${MayrConfig.get('app.name')}');
  print('App Environment: ${MayrConfig.get('app.env')}');
  print('Debug Mode: ${MayrConfig.get('app.debug')}');
  print('App Locale: ${MayrConfig.get('app.locale')}');

  print('\n--- Environment Variable Interpolation ---');
  // These values come from environment variables
  print('API Base URL: ${MayrConfig.get('api.baseUrl')}');
  print('Database Password: ${MayrConfig.get('database.password')}');

  print('\n--- Using String Extension ---');
  // Access configuration using the convenient .mayrConfig() extension
  print('API Timeout: ${'api.timeout'.mayrConfig()}');
  print('Database Host: ${'database.host'.mayrConfig()}');
  print('Database Port: ${'database.port'.mayrConfig()}');
  print('Database Username: ${'database.username'.mayrConfig()}');

  print('\n--- Default Values ---');
  // Provide default values for missing keys
  print('Missing Key: ${MayrConfig.get('missing.key', 'default-value')}');
  print('Another Missing: ${'another.missing'.mayrConfig('fallback')}');

  print('\n--- Configuration Utilities ---');
  // Check if a key exists
  print('Has app.name? ${MayrConfig.has('app.name')}');
  print('Has missing.key? ${MayrConfig.has('missing.key')}');

  // Get all configuration keys
  print('\nAll Keys:');
  for (var key in MayrConfig.keys()) {
    print('  - $key: ${MayrConfig.get(key)}');
  }

  print('\n--- Reload Configuration ---');
  // Reload configuration at runtime
  await MayrConfig.reload();
  print('Configuration reloaded successfully!');

  print('\n=== Example Complete ===');
}
