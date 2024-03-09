import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'environment_keys.dart';

class AppEnvironment {
  static const _defaultEnvFile = 'env/.default.env';
  static const _stagingEnvFile = 'env/.staging.env';
  static const _productionEnvFile = 'env/.production.env';

  static _AppEnvironmentKeys? _config;
  static late final Map<String, String> _envData;

  static Future<void> initialize() async {
    final Map<String, String> defaultConfig;
    Map<String, String> finalConfig;

    try {
      defaultConfig = await _loadDefaultConfig();
    } on Error catch (error) {
      log('[AppEnvironment]:[initialize]:[_loadDefaultConfig]: ${error.runtimeType} error loading $_defaultEnvFile. '
          'Are you sure '
          '$_defaultEnvFile '
          'in present in '
          'the project directory and listed under assets in pubspec.yaml?');
      rethrow;
    }

    try {
      final Map<String, String> config;

      if (kReleaseMode) {
        config = await _loadConfig(_productionEnvFile, defaultConfig);
      } else {
        config = await _loadConfig(_stagingEnvFile, defaultConfig);
      }

      finalConfig = config;
    } on Error catch (error) {
      finalConfig = defaultConfig;
      log('[AppEnvironment]:[initialize]:[_loadConfig(_,_)]: ${error.runtimeType} error loading config file. Using '
          '$_defaultEnvFile as '
          'fallback.');
    }

    _envData = finalConfig;
  }

  static Future<Map<String, String>> _loadDefaultConfig() async {
    final defaultConfig = <String, String>{};

    await dotenv.load(fileName: _defaultEnvFile);
    defaultConfig.addAll(dotenv.env);

    return defaultConfig;
  }

  static Future<Map<String, String>> _loadConfig(
      String filename, Map<String, String> defaultConfig) async {
    final config = <String, String>{};

    await dotenv.load(fileName: filename);
    config.addAll(dotenv.env);

    for (final key in defaultConfig.keys) {
      config.putIfAbsent(key, () => defaultConfig[key]!);
    }

    return config;
  }

  static _AppEnvironmentKeys get config {
    if (_config == null) {
      AppEnvironment._internal();
    }

    return _config!;
  }

  AppEnvironment._internal() {
    _config = _AppEnvironmentKeys(_envData);
  }
}
