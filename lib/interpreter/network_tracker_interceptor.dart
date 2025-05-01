import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../services/network_request.dart';
import '../services/network_request_storage.dart';
import '../services/request_status.dart';

class NetworkTrackerInterceptor extends Interceptor {
  final storage = NetworkRequestStorage.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (storage.baseUrl.isEmpty) {
      storage.baseUrl = options.baseUrl;
    }

    final request = NetworkRequest(
      id: Uuid().v1(),
      path: options.path,
      method: options.method,
      timestamp: DateTime.now(),
      requestData: options.data,
      headers: options.headers,
      queryParameters: options.queryParameters,
      status: RequestStatus.sent,
    );

    storage.addRequest(request);
    options.extra['network_tracker_id'] = request.id;

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra['network_tracker_id'];
    storage.updateRequest(
      requestId,
      status: RequestStatus.completed,
      responseData: response.data,
      statusCode: response.statusCode,
      responseHeaders: response.headers.map,
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['network_tracker_id'];
    storage.updateRequest(
      requestId,
      status: RequestStatus.failed,
      error: err.message,
      statusCode: err.response?.statusCode,
      responseData: err.response?.data,
    );

    super.onError(err, handler);
  }
}
