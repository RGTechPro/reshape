part of '../dio.dart';

class DioTokenInvalidInterceptor extends Interceptor {

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ///401 is for authentication
    if (response.statusCode == 401) {
      
    } else if (response.statusCode == 403) {
      ///403 is for authorization
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    log('status code : ${err.response?.statusCode}');

    return super.onError(
      err,
      handler,
    );
  }
}
