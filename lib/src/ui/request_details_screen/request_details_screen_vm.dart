import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';

class RequestDetailsScreenVM {
  final String path;
  ValueNotifier<List<NetworkRequest>> requestsNotifier = ValueNotifier([]);
  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());

  late final StreamSubscription _repeatRequestSubscription;

  RequestDetailsScreenVM(this.path) {
    requestsNotifier.value =
        NetworkRequestService.instance.storageService.getRequestsByPath(path);
    filterNotifier.addListener(_updateList);

    _repeatRequestSubscription = NetworkRequestService
        .instance.eventService.onRepeatRequestDone.stream
        .listen((_) => _updateList());
  }

  void dispose() {
    requestsNotifier.dispose();
    filterNotifier.dispose();
    _repeatRequestSubscription.cancel();
  }

  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
  }

  void clearFilter() {
    filterNotifier.value = NetworkRequestFilter();
  }

  void _updateList() {
    final filter = filterNotifier.value;
    List<NetworkRequest> requests =
        NetworkRequestService.instance.storageService.getRequestsByPath(path);

    if (filter.method != null) {
      requests = requests.where((r) => r.method == filter.method).toList();
    }

    if (filter.status != null) {
      requests = requests.where((r) => r.status == filter.status).toList();
    }

    requestsNotifier.value = requests;
  }
}
