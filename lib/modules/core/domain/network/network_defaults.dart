part of 'network.dart';

class _AppNetworkHeaderKeys {
  static const String contentType = 'Content-Type';
}

class AppNetworkingDefaults {
  AppNetworkingDefaults._();

  final String baseUrl = AppEnvironment.config.openAIApiKey;

  final Map<String, String> defaultHeaders = {
    _AppNetworkHeaderKeys.contentType: 'application/json',
  };
}
