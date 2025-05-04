import 'package:flutter/foundation.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';
import '../../services/network_request_service.dart';

class NetworkRequestViewerVM {
  late final storage = NetworkRequestService.instance.storage;

  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());
  final ValueNotifier<List<List<NetworkRequest>>> filteredRequestsNotifier =
      ValueNotifier([]);

  NetworkRequestViewerVM() {
    _updateList();
  }

  void search(String query) {
    filterNotifier.value = filterNotifier.value.copy(searchQuery: query);
    _updateList();
  }

  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
    _updateList();
  }

  void clearFilter() {
    filterNotifier.value = NetworkRequestFilter();
    _updateList();
  }

  void clearSearchText() {
    filterNotifier.value = filterNotifier.value.copy(searchQuery: '');
    _updateList();
  }

  void _updateList() {
    final List<List<NetworkRequest>> updatedRequest = [];
    List<String> allPaths = storage.getTrackedPaths();
    final filter = filterNotifier.value;

    if (filter.searchQuery.isNotEmpty) {
      allPaths = allPaths
          .where((path) =>
              path.toLowerCase().contains(filter.searchQuery.toLowerCase()))
          .toList();
    }

    for (var p in allPaths) {
      List<NetworkRequest> requests = storage.getRequestsByPath(p);

      final method = filter.method;
      if (method != null) {
        requests = requests.where((r) => r.method == method).toList();
      }

      final status = filter.status;
      if (status != null) {
        requests = requests.where((r) => r.status == status).toList();
      }

      if (requests.isNotEmpty) {
        updatedRequest.add(requests);
      }
    }

    filteredRequestsNotifier.value = updatedRequest;
  }
}
