import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';

/// View model for endpoint-level request history details.
class RequestDetailsScreenVM {
  /// Base URL whose endpoint history is displayed.
  final String baseUrl;

  /// Endpoint path whose history is displayed.
  final String path;

  /// Notifies listeners with requests matching the current filter.
  ValueNotifier<List<NetworkRequest>> requestsNotifier = ValueNotifier([]);

  /// Holds the active request filter for this endpoint.
  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());

  late final StreamSubscription _repeatRequestSubscription;

  /// Creates a [RequestDetailsScreenVM] instance.
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

  /// Releases resources held by this instance.
  void dispose() {
    requestsNotifier.dispose();
    filterNotifier.dispose();
    _repeatRequestSubscription.cancel();
  }

  /// Updates the active filter and refreshes the list.
  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
  }

  /// Clears filter.
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
