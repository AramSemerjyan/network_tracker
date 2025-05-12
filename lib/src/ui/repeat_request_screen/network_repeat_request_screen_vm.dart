import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';

class NetworkRepeatRequestScreenVM {
  late final String baseUrl;
  final repeatService = NetworkRequestService.instance.repeatRequestService;
  late final ValueNotifier<List<NetworkRequest>> availableRequestsNotifier =
      ValueNotifier([]);

  NetworkRepeatRequestScreenVM(this.baseUrl) {
    repeatService.repeatableRequests(baseUrl: baseUrl).then((list) {
      availableRequestsNotifier.value = list;
    });
  }

  void repeatRequest(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
