import 'package:dio/dio.dart';

class NetworkTrackerRequestModifierInterceptor extends Interceptor {

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    response.requestOptions.extra['network_tracker_modified_response'] =
        true;

    super.onResponse(response, handler);
  }
}