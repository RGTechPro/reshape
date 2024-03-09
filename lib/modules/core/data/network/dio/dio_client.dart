part of 'dio.dart';

class DioOptions {
  final String? baseUrl;
  final Map<String, String>? headers;
  final ResponseType? responseType;

  DioOptions({
    this.baseUrl,
    this.headers,
    this.responseType,
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
            responseType: _dio.defaultOptions.responseType??ResponseType.json,
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
            responseType: options.responseType??ResponseType.json,
          ),
        );
}
