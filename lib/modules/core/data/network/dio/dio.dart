import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

part 'dio_client.dart';
part 'interceptors/logging.dart';
part 'interceptors/no_token.dart';

class AppDio {
  final DioOptions defaultOptions;

  AppDio({
    required this.defaultOptions,
  });

  Future<AppDioClient> client({
    DioOptions? options,
    String? accessToken,
    required bool loggingEnabled,
  }) async {
    late AppDioClient client;

    if (accessToken != null) {
      client = await _createSecureClient(
        accessToken: accessToken,
        options: options,
      );
    } else {
      client = await _createUnsecureClient(
        options: options,
      );
    }

    if (loggingEnabled) {
      client.addLoggingIntercept();
    }

    return client;
  }

  Future<AppDioClient> _createUnsecureClient({
    DioOptions? options,
  }) async {
    final client = options != null
        ? AppDioClient.fromOptions(
            this,
            options,
          )
        : AppDioClient(
            this,
          );

    return client;
  }

  Future<AppDioClient> _createSecureClient({
    required String accessToken,
    DioOptions? options,
  }) async {
    final client = options != null
        ? AppDioClient.fromOptions(
            this,
            options,
            authorizationToken: accessToken,
          )
        : AppDioClient(
            this,
            authorizationToken: accessToken,
          );

    return client;
  }
}

extension DioClientX on AppDioClient {
  void addLoggingIntercept() {
    interceptors.add(DioNetworkLoggingInterceptor());
    interceptors.add(DioTokenInvalidInterceptor());
  }
}
