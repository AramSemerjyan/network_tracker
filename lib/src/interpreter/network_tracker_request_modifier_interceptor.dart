import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/services/request_status.dart';

class NetworkTrackerRequestModifierInterceptor extends Interceptor {
  /// Reference to the storage service for updating request records.
  final _storage = NetworkRequestService.instance.storageService;

  /// Intercepts Dio responses and applies modifications if configured.
  ///
  /// If a modification is found for the request, it can delay the response,
  /// alter its contents, or simulate a failure. Updates the request record
  /// in storage accordingly.
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // Check if this response was already modified to avoid double processing.
    final alreadyModified =
        response.requestOptions.extra['network_tracker_modified_response'] ==
            true;
    if (!alreadyModified) {
      // Look up any response modification for this request.
      final modification =
          NetworkRequestService.instance.getResponseModification(
        baseUrl: response.requestOptions.baseUrl,
        path: response.requestOptions.path,
        method: NetworkRequestMethod.fromString(response.requestOptions.method),
      );

      if (modification != null) {
        // Optionally delay the response if specified.
        final delay = modification.delay;
        if (delay != null && delay.inMilliseconds > 0) {
          await Future.delayed(delay);
        }
        // Apply the modification to the response.
        final modified = modification.applyTo(response);
        modified.requestOptions.extra['network_tracker_modified_response'] =
            true;

        // If the modification simulates a failure, reject the response.
        if (modification.isFailure(modified)) {
          final statusCode = modification.effectiveStatusCode(modified) ??
              modified.statusCode ??
              500;
          final error = DioException.badResponse(
            statusCode: statusCode,
            requestOptions: modified.requestOptions,
            response: modified,
          );
          final requestId = modified.requestOptions.extra['network_tracker_id'];
          if (requestId is String) {
            _storage.updateRequest(
              requestId,
              requestOptions: modified.requestOptions,
              response: modified,
              status: resolveRequestStatus(
                statusCode: statusCode,
                error: error,
              ),
              endDate: DateTime.now(),
              dioError: error,
              isModified: true,
            );
          }
          handler.reject(error);
          return;
        }
        // Otherwise, update the request as successful and continue.
        final requestId = modified.requestOptions.extra['network_tracker_id'];
        if (requestId is String) {
          _storage.updateRequest(
            requestId,
            requestOptions: modified.requestOptions,
            response: modified,
            status: resolveRequestStatus(statusCode: modified.statusCode),
            endDate: DateTime.now(),
            isModified: true,
          );
        }
        handler.next(modified);
        return;
      }
    }

    // If no modification, proceed with the original response.
    super.onResponse(response, handler);
  }
}
