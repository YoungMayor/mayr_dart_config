import 'package:mayr_config/mayr_config.dart';
import 'lib/config.g.dart';

/// Example demonstrating type-safe generated configuration accessors.
Future<void> main() async {
  print('=== Generated Config Example ===\n');

  // Load configuration
  await MayrConfig.loadFromYaml('config.yaml');

  print('--- Using Generated Classes ---');
  // Access configuration using type-safe generated classes
  print('App Name: ${Config.app.name}');
  print('App Debug: ${Config.app.debug}');
  print('App Env: ${Config.app.env}');
  print('App Locale: ${Config.app.locale}');

  print('\nAPI Configuration:');
  print('  Base URL: ${Config.api.baseurl}');
  print('  Timeout: ${Config.api.timeout}');

  print('\nDatabase Configuration:');
  print('  Host: ${Config.database.host}');
  print('  Port: ${Config.database.port}');
  print('  Username: ${Config.database.username}');
  print('  Password: ${Config.database.password}');

  print('\n=== Example Complete ===');
}
