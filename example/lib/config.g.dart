// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: public_member_api_docs

import 'package:mayr_config/mayr_config.dart';

/// Main configuration class providing access to all config sections.
class Config {
  Config._();

  /// Access app configuration.
  static final app = _AppConfig();

  /// Access api configuration.
  static final api = _ApiConfig();

  /// Access database configuration.
  static final database = _DatabaseConfig();
}

/// Configuration class for app.
class _AppConfig {
  const _AppConfig();

  String get name => MayrConfig.get('app.name');
  String get env => MayrConfig.get('app.env');
  bool get debug => MayrConfig.get('app.debug');
  String get locale => MayrConfig.get('app.locale');
}

/// Configuration class for api.
class _ApiConfig {
  const _ApiConfig();

  String get baseurl => MayrConfig.get('api.baseUrl');
  int get timeout => MayrConfig.get('api.timeout');
}

/// Configuration class for database.
class _DatabaseConfig {
  const _DatabaseConfig();

  String get host => MayrConfig.get('database.host');
  int get port => MayrConfig.get('database.port');
  String get username => MayrConfig.get('database.username');
  String get password => MayrConfig.get('database.password');
}
