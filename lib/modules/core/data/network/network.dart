import 'dart:developer';

import 'package:reshape/environment/environment.dart';
import 'package:reshape/modules/core/data/network/dio/dio.dart';
import 'package:reshape/modules/core/domain/network/network.dart';

class AppNetworkingBoxImpl implements AppNetworkingBox<AppDioClient, DioOptions> {
  late AppDio _networkService;

  AppNetworkingBoxImpl() {
    _networkService = AppDio(
      defaultOptions: DioOptions(
        baseUrl: AppNetworkingBox.defaults.baseUrl,
        headers: AppNetworkingBox.defaults.defaultHeaders,
      ),
    );
  }

  @override
  Future bootUp() {
    log('[NetworkingBox.bootUp]');
    // TODO: implement bootUp
    throw UnimplementedError();
  }

  @override
  void onBootUp() {
    // TODO: implement onBootUp
  }

  @override
  void bootDown() {
    log('[NetworkingBox.bootDown]');
    // TODO: implement bootDown
  }

  @override
  Future<AppDioClient?> secureClient({
    DioOptions? options,
    bool loggingEnabled = true,
  }) async {
    AppDioClient? client;
    //TODO: improve approach for access token

    final isAuthenticated = AppEnvironment.config.openAIApiKey !='';

    if (isAuthenticated) {
      final accessToken = AppEnvironment.config.openAIApiKey;

      client = await _networkService.client(
        options: options,
        accessToken: accessToken,
        loggingEnabled: loggingEnabled,
      );
    } else {
      log('[secureClient] Client could not be created');
    }

    return client;
  }

  @override
  Future<AppDioClient> unsecureClient({
    DioOptions? options,
    bool loggingEnabled = true,
  }) async {
    final client = await _networkService.client(
      options: options,
      loggingEnabled: loggingEnabled,
    );

    return client;
  }
}
