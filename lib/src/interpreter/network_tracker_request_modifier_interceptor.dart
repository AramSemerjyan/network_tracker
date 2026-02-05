import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/services/request_status.dart';

class NetworkTrackerRequestModifierInterceptor extends Interceptor {
  final _storage = NetworkRequestService.instance.storageService;

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final alreadyModified =
        response.requestOptions.extra['network_tracker_modified_response'] ==
            true;
    if (!alreadyModified) {
      final modification =
          NetworkRequestService.instance.getResponseModification(
        baseUrl: response.requestOptions.baseUrl,
        path: response.requestOptions.path,
        method: NetworkRequestMethod.fromString(response.requestOptions.method),
      );

      if (modification != null) {
        final delay = modification.delay;
        if (delay != null && delay.inMilliseconds > 0) {
          await Future.delayed(delay);
        }
        final modified = modification.applyTo(response);
        modified.requestOptions.extra['network_tracker_modified_response'] =
            true;

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

    super.onResponse(response, handler);
  }
}
