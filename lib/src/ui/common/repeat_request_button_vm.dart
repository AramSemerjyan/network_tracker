import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';

/// View model for repeat-request actions.
class RepeatRequestButtonVM {
  /// Service that replays captured requests.
  final repeatService = NetworkRequestService.instance.repeatRequestService;

  /// Re-sends the provided tracked [request].
  void repeat(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
