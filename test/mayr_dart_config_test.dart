import 'dart:io';
import 'package:test/test.dart';
import 'package:mayr_config/mayr_config.dart';

void main() {
  late String testConfigPath;
  late String testEnvPath;
  late Directory testDir;

  setUp(() async {
    // Create a temporary directory for test files
    testDir = await Directory.systemTemp.createTemp('mayr_config_test_');
    testConfigPath = '${testDir.path}/test_config.yaml';
    testEnvPath = '${testDir.path}/test.env';

    // Create test .env file
    await File(testEnvPath).writeAsString('''
TEST_ENV=testing
TEST_URL=https://test.example.com
TEST_PASSWORD=secret123
''');

    // Create test config.yaml file
    await File(testConfigPath).writeAsString('''
app:
  name: TestApp
  env: \${TEST_ENV}
  debug: true
  version: 1.0.0
  
api:
  baseUrl: \${TEST_URL}
  timeout: 3000
  retries: 5
  
database:
  host: localhost
  port: 5432
  username: testuser
  password: \${TEST_PASSWORD}
  
nested:
  level1:
    level2:
      value: deep-value
      
list:
  - item1
  - item2
  - item3
''');

    // Clear any previous configuration
    MayrConfig.clear();
  });

  tearDown(() async {
    // Clean up test files
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    MayrConfig.clear();
  });

  group('MayrEnv', () {
    test('loads environment variables from .env file', () async {
      await MayrEnv.load(testEnvPath);

      expect(MayrEnv.get('TEST_ENV'), equals('testing'));
      expect(MayrEnv.get('TEST_URL'), equals('https://test.example.com'));
      expect(MayrEnv.get('TEST_PASSWORD'), equals('secret123'));
    });

    test('returns null for non-existent keys', () async {
      await MayrEnv.load(testEnvPath);
      expect(MayrEnv.get('NON_EXISTENT'), isNull);
    });

    test('handles missing .env file gracefully', () async {
      await MayrEnv.load('nonexistent.env');
      // Should not throw
    });

    test('handles quotes in values', () async {
      final quotedEnvPath = '${testDir.path}/quoted.env';
      await File(quotedEnvPath).writeAsString('''
SINGLE_QUOTED='value with spaces'
DOUBLE_QUOTED="another value"
NO_QUOTES=simple
''');

      await MayrEnv.load(quotedEnvPath);

      expect(MayrEnv.get('SINGLE_QUOTED'), equals('value with spaces'));
      expect(MayrEnv.get('DOUBLE_QUOTED'), equals('another value'));
      expect(MayrEnv.get('NO_QUOTES'), equals('simple'));
    });

    test('ignores comments and empty lines', () async {
      final commentEnvPath = '${testDir.path}/comments.env';
      await File(commentEnvPath).writeAsString('''
# This is a comment
KEY1=value1

# Another comment
KEY2=value2

''');

      await MayrEnv.load(commentEnvPath);

      expect(MayrEnv.get('KEY1'), equals('value1'));
      expect(MayrEnv.get('KEY2'), equals('value2'));
    });
  });

  group('MayrConfig', () {
    test('loads configuration from YAML file', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.get('app.name'), equals('TestApp'));
      expect(MayrConfig.get('app.debug'), equals(true));
      expect(MayrConfig.get('app.version'), equals('1.0.0'));
    });

    test('interpolates environment variables', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.get('app.env'), equals('testing'));
      expect(MayrConfig.get('api.baseUrl'), equals('https://test.example.com'));
      expect(MayrConfig.get('database.password'), equals('secret123'));
    });

    test('accesses nested values with dot notation', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.get('database.host'), equals('localhost'));
      expect(MayrConfig.get('database.port'), equals(5432));
      expect(MayrConfig.get('nested.level1.level2.value'), equals('deep-value'));
    });

    test('returns default value for missing keys', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.get('missing.key', 'default'), equals('default'));
      expect(MayrConfig.get('another.missing', 42), equals(42));
    });

    test('checks if key exists', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.has('app.name'), isTrue);
      expect(MayrConfig.has('missing.key'), isFalse);
    });

    test('returns all configuration keys', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      final keys = MayrConfig.keys().toList();

      expect(keys, contains('app.name'));
      expect(keys, contains('api.baseUrl'));
      expect(keys, contains('database.port'));
      expect(keys.length, greaterThan(5));
    });

    test('reloads configuration', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.get('app.name'), equals('TestApp'));

      // Modify the config file
      await File(testConfigPath).writeAsString('''
app:
  name: UpdatedApp
  debug: false
''');

      await MayrConfig.reload();

      expect(MayrConfig.get('app.name'), equals('UpdatedApp'));
      expect(MayrConfig.get('app.debug'), equals(false));
    });

    test('clears configuration', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect(MayrConfig.has('app.name'), isTrue);

      MayrConfig.clear();

      expect(MayrConfig.has('app.name'), isFalse);
    });

    test('throws error for non-existent config file', () async {
      expect(
        () => MayrConfig.loadFromYaml('nonexistent.yaml'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('uses load() convenience method', () async {
      await MayrConfig.load(
        yamlPath: testConfigPath,
        envPath: testEnvPath,
      );

      expect(MayrConfig.get('app.name'), equals('TestApp'));
      expect(MayrConfig.get('app.env'), equals('testing'));
    });
  });

  group('String Extension', () {
    test('provides mayrConfig() shorthand', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect('app.name'.mayrConfig(), equals('TestApp'));
      expect('api.timeout'.mayrConfig(), equals(3000));
      expect('database.username'.mayrConfig(), equals('testuser'));
    });

    test('supports default values in mayrConfig()', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      expect('missing.key'.mayrConfig('default'), equals('default'));
      expect('another.missing'.mayrConfig(999), equals(999));
    });
  });

  group('Type Handling', () {
    test('preserves different data types', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      // String
      expect(MayrConfig.get('app.name'), isA<String>());
      expect(MayrConfig.get('app.name'), equals('TestApp'));

      // Boolean
      expect(MayrConfig.get('app.debug'), isA<bool>());
      expect(MayrConfig.get('app.debug'), equals(true));

      // Integer
      expect(MayrConfig.get('api.timeout'), isA<int>());
      expect(MayrConfig.get('api.timeout'), equals(3000));

      // String (from version number)
      expect(MayrConfig.get('app.version'), isA<String>());
      expect(MayrConfig.get('app.version'), equals('1.0.0'));
    });

    test('handles list values', () async {
      await MayrConfig.loadFromYaml(testConfigPath, testEnvPath);

      final listValue = MayrConfig.get('list');
      expect(listValue, isA<List>());
      expect(listValue.length, equals(3));
      expect(listValue, contains('item1'));
      expect(listValue, contains('item2'));
      expect(listValue, contains('item3'));
    });
  });

  group('Edge Cases', () {
    test('handles empty YAML file', () async {
      final emptyConfigPath = '${testDir.path}/empty.yaml';
      await File(emptyConfigPath).writeAsString('');

      await MayrConfig.loadFromYaml(emptyConfigPath, testEnvPath);

      expect(MayrConfig.keys().length, equals(0));
    });

    test('handles YAML with only comments', () async {
      final commentConfigPath = '${testDir.path}/comments.yaml';
      await File(commentConfigPath).writeAsString('''
# Just a comment
# Another comment
''');

      await MayrConfig.loadFromYaml(commentConfigPath, testEnvPath);

      expect(MayrConfig.keys().length, equals(0));
    });

    test('handles environment variable not found in interpolation', () async {
      final missingEnvConfigPath = '${testDir.path}/missing_env.yaml';
      await File(missingEnvConfigPath).writeAsString('''
app:
  url: \${MISSING_ENV_VAR}
''');

      await MayrConfig.loadFromYaml(missingEnvConfigPath, testEnvPath);

      // Should keep the placeholder when env var is not found
      expect(MayrConfig.get('app.url'), equals('\${MISSING_ENV_VAR}'));
    });

    test('handles multiple environment variable interpolations', () async {
      final multiEnvPath = '${testDir.path}/multi.env';
      await File(multiEnvPath).writeAsString('''
PROTOCOL=https
DOMAIN=example.com
PORT=8080
''');

      final multiConfigPath = '${testDir.path}/multi.yaml';
      await File(multiConfigPath).writeAsString('''
app:
  url: \${PROTOCOL}://\${DOMAIN}:\${PORT}
''');

      await MayrConfig.loadFromYaml(multiConfigPath, multiEnvPath);

      expect(MayrConfig.get('app.url'), equals('https://example.com:8080'));
    });
  });
}
