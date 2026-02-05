import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

class NetworkTrackerRequestModifierInterceptor extends Interceptor {
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    print('from modifier interceptor');

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
        // handler.next(modified);
        super.onResponse(modified, handler);
        return;
      }
    }

    super.onResponse(response, handler);
  }
}
