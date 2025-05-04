import 'dart:async';

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

  Timer? _debounce;

  NetworkRequestViewerVM() {
    filterNotifier.addListener(_updateList);
    _updateList();
  }

  void dispose() {
    filterNotifier.dispose();
    filteredRequestsNotifier.dispose();

    _debounce?.cancel();
    _debounce = null;
  }

  void search(String query) {
    _debounce?.cancel();
    if (filterNotifier.value.searchQuery != query) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        filterNotifier.value = filterNotifier.value.copy(searchQuery: query);
      });
    }
  }

  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
  }

  void clearFilter() {
    filterNotifier.value = NetworkRequestFilter();
  }

  void clearSearchText() {
    filterNotifier.value = filterNotifier.value.copy(searchQuery: '');
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
