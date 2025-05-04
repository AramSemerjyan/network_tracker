import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';
import '../../services/network_request_service.dart';

class NetworkRequestViewerVM {
  final storage = NetworkRequestService.instance.storage;

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
    filterNotifier.removeListener(_updateList);
    filterNotifier.dispose();
    filteredRequestsNotifier.dispose();
    _debounce?.cancel();
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final current = filterNotifier.value;
      if (current.searchQuery != query) {
        filterNotifier.value = current.copy(searchQuery: query);
      }
    });
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

  void clearSpecificFilter({
    bool clearMethod = false,
    bool clearStatus = false,
  }) {
    final current = filterNotifier.value;
    filterNotifier.value = NetworkRequestFilter(
      method: clearMethod ? null : current.method,
      status: clearStatus ? null : current.status,
      searchQuery: current.searchQuery,
    );
  }

  void _updateList() {
    final filter = filterNotifier.value;
    filteredRequestsNotifier.value = storage.getFilteredGroups(filter);
  }
}
