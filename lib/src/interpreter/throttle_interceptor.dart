import 'package:dio/dio.dart';

class ThrottleInterceptor extends Interceptor {
  final int maxBytesPerSecond;

  ThrottleInterceptor(this.maxBytesPerSecond);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.data is List<int>) {
      final length = (response.data as List<int>).length;
      final delayMs = (length / maxBytesPerSecond * 1000).ceil();
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}
