import 'package:mayr_config/mayr_config.dart';

/// Simple example demonstrating basic MayrConfig usage.
///
/// This shows the simplest way to use MayrConfig with a single config file.
Future<void> main() async {
  print('=== Simple MayrConfig Example ===\n');

  // Load configuration from a single file
  print('Loading configuration from config.yaml...');
  await MayrConfig.load('example/config.yaml', 'example/.env');
  print('✅ Configuration loaded!\n');

  // Access configuration values
  print('--- Configuration Values ---');
  print('App Name:     ${MayrConfig.get('app.name')}');
  print('App Env:      ${MayrConfig.get('app.env')}');
  print('Debug Mode:   ${MayrConfig.get('app.debug')}');
  print('');
  print('API URL:      ${MayrConfig.get('api.baseUrl')}');
  print('API Timeout:  ${MayrConfig.get('api.timeout')} ms');
  print('');
  print('DB Host:      ${MayrConfig.get('database.host')}');
  print('DB Port:      ${MayrConfig.get('database.port')}');

  // Using string extension
  print('\n--- Using String Extension ---');
  print('App Name:     ${'app.name'.config}');
  print('API Timeout:  ${'api.timeout'.config} ms');

  // Type-safe access
  print('\n--- Type-Safe Access ---');
  final timeout = MayrConfig.getValue<int>('api.timeout');
  final debug = MayrConfig.getValue<bool>('app.debug');
  print('Timeout (int):  $timeout');
  print('Debug (bool):   $debug');

  print('\n=== Example Complete ===');
}
