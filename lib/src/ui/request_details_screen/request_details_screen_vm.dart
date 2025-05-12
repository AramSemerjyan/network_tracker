import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';

class RequestDetailsScreenVM {
  final String baseUrl;
  final String path;
  ValueNotifier<List<NetworkRequest>> requestsNotifier = ValueNotifier([]);
  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());

  late final StreamSubscription _repeatRequestSubscription;

  RequestDetailsScreenVM(this.baseUrl, this.path) {
    NetworkRequestService.instance.storageService
        .getRequestsByPath(path, baseUrl)
        .then((list) {
      requestsNotifier.value = list;
    });
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

  void _updateList() async {
    final filter = filterNotifier.value;
    List<NetworkRequest> requests = await NetworkRequestService
        .instance.storageService
        .getRequestsByPath(path, baseUrl);

    if (filter.method != null) {
      requests = requests.where((r) => r.method == filter.method).toList();
    }

    if (filter.status != null) {
      requests = requests.where((r) => r.status == filter.status).toList();
    }

    if (filter.isRepeated != null) {
      requests =
          requests.where((r) => r.isRepeated == filter.isRepeated).toList();
    }

    requestsNotifier.value = requests;
  }
}
