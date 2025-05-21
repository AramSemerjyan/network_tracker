import 'package:dio/dio.dart';

class NetworkThrottleInterceptor extends Interceptor {
  final int maxBytesPerSecond;

  NetworkThrottleInterceptor(this.maxBytesPerSecond);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.data is List<int>) {
      final length = (response.data as List<int>).length;
      final delayMs = (length / maxBytesPerSecond * 1000).ceil();
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    response.requestOptions.extra['is_throttled'] = true;

    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}
