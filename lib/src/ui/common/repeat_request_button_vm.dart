import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';

class RepeatRequestButtonVM {
  final repeatService = NetworkRequestService.instance.repeatRequestService;

  void repeat(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
