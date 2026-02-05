import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../model/network_request.dart';
import '../services/request_status.dart';
import '../services/storage/network_request_local_storage.dart';

/// A Dio interceptor that tracks all outgoing requests, responses, and errors.
///
/// This interceptor records metadata such as method, path, headers,
/// status code, response body, and any errors. The data is stored in
/// [NetworkRequestLocalStorage] and can be visualized using a UI like
/// `NetworkRequestsViewer`.
///
/// To use:
/// ```dart
/// dio.interceptors.add(NetworkTrackerInterceptor());
/// ```
class NetworkTrackerInterceptor extends Interceptor {
  /// Internal request storage for tracking all captured requests.
  final storage = NetworkRequestService.instance.storageService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final startDate = DateTime.now();

    final request = NetworkRequest(
      id: Uuid().v1(),
      path: options.path,
      baseUrl: options.baseUrl,
      method: NetworkRequestMethod.fromString(options.method),
      startDate: startDate,
      requestData: options.data,
      headers: options.headers,
      queryParameters: options.queryParameters,
      status: RequestStatus.sent,
      requestSizeBytes: Utils.estimateSize(options.data),
      isRepeated: options.extra['is_repeated'] ?? false,
    );

    storage.addRequest(request);

    /// Store request ID to associate with later response or error
    options.extra['network_tracker_id'] = request.id;
    options.extra['network_tracker_start_time'] = startDate;

    super.onRequest(options, handler);
  }

  /// Retrieve stored request ID and update with response details
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final requestId = response.requestOptions.extra['network_tracker_id'];
    final status = resolveRequestStatus(statusCode: response.statusCode);
    storage.updateRequest(
      requestId,
      requestOptions: response.requestOptions,
      response: response,
      status: status,
      endDate: DateTime.now(),
    );

    super.onResponse(response, handler);
  }

  /// Retrieve stored request ID and update with error details
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['network_tracker_id'];
    final status = resolveRequestStatus(
      statusCode: err.response?.statusCode,
      error: err,
    );
    storage.updateRequest(
      requestId,
      response: err.response,
      requestOptions: err.requestOptions,
      status: status,
      endDate: DateTime.now(),
      dioError: err,
    );

    super.onError(err, handler);
  }
}
