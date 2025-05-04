import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:uuid/uuid.dart';

import '../model/network_request.dart';
import '../services/network_request_storage.dart';
import '../services/request_status.dart';

/// A Dio interceptor that tracks all outgoing requests, responses, and errors.
///
/// This interceptor records metadata such as method, path, headers,
/// status code, response body, and any errors. The data is stored in
/// [NetworkRequestStorage] and can be visualized using a UI like
/// `NetworkRequestsViewer`.
///
/// To use:
/// ```dart
/// dio.interceptors.add(NetworkTrackerInterceptor());
/// ```
class NetworkTrackerInterceptor extends Interceptor {
  /// Internal request storage for tracking all captured requests.
  final storage = NetworkRequestService.instance.storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    /// Capture and store request data
    if (storage.baseUrl.isEmpty) {
      storage.setBaseUrl(options.baseUrl);
    }

    final startDate = DateTime.now();

    final request = NetworkRequest(
      id: Uuid().v1(),
      path: options.path,
      method: NetworkRequestMethod.fromString(options.method),
      startDate: startDate,
      requestData: options.data,
      headers: options.headers,
      queryParameters: options.queryParameters,
      status: RequestStatus.sent,
    );

    storage.addRequest(request);

    /// Store request ID to associate with later response or error
    options.extra['network_tracker_id'] = request.id;
    options.extra['network_tracker_start_time'] = startDate;

    super.onRequest(options, handler);
  }

  /// Retrieve stored request ID and update with response details
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra['network_tracker_id'];
    storage.updateRequest(requestId,
        status: RequestStatus.completed,
        responseData: response.data,
        statusCode: response.statusCode,
        responseHeaders: response.headers.map,
        endDate: DateTime.now());

    super.onResponse(response, handler);
  }

  /// Retrieve stored request ID and update with error details
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['network_tracker_id'];
    storage.updateRequest(
      requestId,
      status: RequestStatus.failed,
      statusCode: err.response?.statusCode,
      responseData: err.response?.data,
      endDate: DateTime.now(),
      dioError: err,
    );

    super.onError(err, handler);
  }
}
