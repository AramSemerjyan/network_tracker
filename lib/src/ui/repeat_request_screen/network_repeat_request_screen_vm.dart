import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';

/// View model for loading and replaying requests on repeat screen.
class NetworkRepeatRequestScreenVM {
  /// Base URL used to query repeatable requests.
  late final String baseUrl;

  /// Service that replays captured requests.
  final repeatService = NetworkRequestService.instance.repeatRequestService;

  /// Notifies listeners with requests available for repeating.
  late final ValueNotifier<List<NetworkRequest>> availableRequestsNotifier =
      ValueNotifier([]);

  /// Creates a [NetworkRepeatRequestScreenVM] instance.
  NetworkRepeatRequestScreenVM(this.baseUrl) {
    repeatService.repeatableRequests(baseUrl: baseUrl).then((list) {
      availableRequestsNotifier.value = list;
    });
  }

  /// Re-sends a selected tracked [request].
  void repeatRequest(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
