part of 'dio.dart';

class DioOptions {
  final String? baseUrl;
  final Map<String, String>? headers;

  DioOptions({
    this.baseUrl,
    this.headers,
  });
}

class AppDioClient extends DioForNative {
  final AppDio _dio;

  AppDioClient(
    this._dio, {
    String? authorizationToken,

  }) : super(
          BaseOptions(
            baseUrl: _dio.defaultOptions.baseUrl!,
            headers: {
              ..._dio.defaultOptions.headers!,
              if (authorizationToken != null) ...{
                'Authorization': 'Bearer $authorizationToken'
              },
            },
            validateStatus: (_) => true,
          ),
        ) {
    log('Headers : ${_dio.defaultOptions.headers!}');
  }

  AppDioClient.fromOptions(
    this._dio,
    DioOptions options, {
    String? authorizationToken,

  }) : super(
          BaseOptions(
            baseUrl: options.baseUrl ?? _dio.defaultOptions.baseUrl!,
            headers: {
              ..._dio.defaultOptions.headers!,
              if (options.headers != null) ...options.headers!,
              if (authorizationToken != null) ...{
                'Authorization': 'Bearer $authorizationToken'
              },
            },
            validateStatus: (_) => true,
          ),
        );
}
