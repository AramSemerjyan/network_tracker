import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';

class NetworkRepeatRequestScreenVM {
  final repeatService = NetworkRequestService.instance.repeatRequestService;
  late final ValueNotifier<List<NetworkRequest>> availableRequestsNotifier =
      ValueNotifier(repeatService.repeatableRequests);

  void repeatRequest(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
