import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:network_tracker/src/services/connectivity/network_connectivity_service.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';
import '../../services/network_request_service.dart';

class NetworkRequestViewerVM {
  final storageService = NetworkRequestService.instance.storageService;
  final eventService = NetworkRequestService.instance.eventService;

  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());
  final ValueNotifier<List<List<NetworkRequest>>> filteredRequestsNotifier =
      ValueNotifier([]);
  final ValueNotifier<String> selectedBaseUrl = ValueNotifier('');
  final NetworkConnectivityService networkConnectivityService =
      NetworkConnectivityService();

  Timer? _debounce;
  late final StreamSubscription _repeatRequestSubscription;

  NetworkRequestViewerVM() {
    NetworkRequestService.instance.storageService.getUrls().then((list) {
      if (list.isNotEmpty) {
        selectedBaseUrl.value = list.first;
      }
    });

    filterNotifier.addListener(_updateList);
    selectedBaseUrl.addListener(_updateList);
    _updateList();

    _repeatRequestSubscription = NetworkRequestService
        .instance.eventService.onRepeatRequestDone.stream
        .listen((_) => _updateList());
  }

  void dispose() {
    filterNotifier.dispose();
    filteredRequestsNotifier.dispose();
    _debounce?.cancel();
    _repeatRequestSubscription.cancel();
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

  void clearRequestsList() async {
    await storageService.clear();
    _updateList();
  }

  void _updateList() async {
    final filter = filterNotifier.value;
    filteredRequestsNotifier.value =
        await storageService.getFilteredGroups(filter, selectedBaseUrl.value);
  }
}
