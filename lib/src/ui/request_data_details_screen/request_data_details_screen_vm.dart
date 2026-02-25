import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/utils/utils.dart';

import '../../services/network_request_service.dart';

/// View model for request payload details and sharing actions.
class RequestDataDetailsScreenVM {
  /// Request entry currently shown in the details screen.
  final NetworkRequest request;

  /// Repeat-request service used by detail actions.
  final repeatRequestService =
      NetworkRequestService.instance.repeatRequestService;

  /// Creates a [RequestDataDetailsScreenVM] instance.
  RequestDataDetailsScreenVM(this.request);

  /// Exports and shares the response payload for the current request.
  Future<void> shareRequest() async {
    Utils.shareFile(request.responseData, fileName: request.name);
  }
}
