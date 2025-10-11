import 'package:mayr_config/mayr_config.dart';
// Import generated config files after running: dart run build_runner build
// import 'config/app.g.dart';
// import 'config/api.g.dart';
// import 'config/database.g.dart';

/// Example demonstrating type-safe generated configuration accessors.
///
/// To use this example:
/// 1. Run: dart run build_runner build
/// 2. Uncomment the imports above
/// 3. Uncomment the generated code usage below
Future<void> main() async {
  print('=== Generated Config Example ===\n');

  // Load configuration from multiple files
  await MayrConfig.load([
    'example/config/app.yaml',
    'example/config/api.yaml',
    'example/config/database.yaml',
  ], 'example/.env');

  print('--- Using Runtime Access (Before Code Generation) ---');
  print('App Name:     ${MayrConfig.getValue<String>('app.name')}');
  print('App Debug:    ${MayrConfig.getValue<bool>('app.debug')}');
  print('App Version:  ${MayrConfig.getValue<String>('app.version')}');
  print('');
  print('API Base URL: ${MayrConfig.getValue<String>('api.baseUrl')}');
  print('API Timeout:  ${MayrConfig.getValue<int>('api.timeout')}');
  print('');
  print('DB Host:      ${MayrConfig.getValue<String>('database.host')}');
  print('DB Port:      ${MayrConfig.getValue<int>('database.port')}');
  print('DB Username:  ${MayrConfig.getValue<String>('database.username')}');

  print('\n--- After Running build_runner ---');
  print('Uncomment the code below to use generated type-safe accessors:\n');
  print('// Using Generated Classes (Nested Structure):');
  print('// print(\'App Name:    \${App.app.name}\');');
  print('// print(\'App Debug:   \${App.app.debug}\');');
  print('// print(\'App Version: \${App.app.version}\');');
  print('//');
  print('// print(\'API URL:     \${Api.api.baseUrl}\');');
  print('// print(\'API Timeout: \${Api.api.timeout}\');');
  print('//');
  print('// print(\'DB Host:     \${Database.database.host}\');');
  print('// print(\'DB Port:     \${Database.database.port}\');');
  print('// print(\'DB Username: \${Database.database.username}\');');

  print('\n💡 To generate type-safe accessors:');
  print('   1. Run: dart run build_runner build');
  print('   2. Generated files will be created:');
  print('      - example/config/app.g.dart');
  print('      - example/config/api.g.dart');
  print('      - example/config/database.g.dart');
  print('   3. Import them in your code');
  print('   4. Use beautiful nested syntax: App.app.name, Api.api.timeout');

  print('\n=== Example Complete ===');
}
