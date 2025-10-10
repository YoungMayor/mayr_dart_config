import 'package:mayr_config/mayr_config.dart';
import 'lib/config.g.dart';

/// Example demonstrating type-safe generated configuration accessors.
Future<void> main() async {
  print('=== Generated Config Example ===\n');

  // Load configuration
  await MayrConfig.loadFromYaml('config.yaml');

  print('--- Using Generated Classes ---');
  // Access configuration using type-safe generated classes
  print('App Name: ${AppConfig.name}');
  print('App Debug: ${AppConfig.debug}');
  print('App Env: ${AppConfig.env}');
  print('App Locale: ${AppConfig.locale}');

  print('\nAPI Configuration:');
  print('  Base URL: ${ApiConfig.baseurl}');
  print('  Timeout: ${ApiConfig.timeout}');

  print('\nDatabase Configuration:');
  print('  Host: ${DatabaseConfig.host}');
  print('  Port: ${DatabaseConfig.port}');
  print('  Username: ${DatabaseConfig.username}');
  print('  Password: ${DatabaseConfig.password}');

  print('\n=== Example Complete ===');
}

