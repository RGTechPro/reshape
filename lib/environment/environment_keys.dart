part of 'environment.dart';

class _AppEnvironmentKeys {
  final Map<String, String> _envConfig;

  _AppEnvironmentKeys(this._envConfig);

  /// Either `production` or `staging`
  String get environment => _envConfig['ENVIRONMENT']!;


  String get openApiUrl => _envConfig['OPEN_AI_API_URL']!;


  String get openAIApiKey => _envConfig['OPEN_AI_API_KEY']!;


}