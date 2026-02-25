import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';
import '../../services/network_request_service.dart';

/// View model for the top-level requests viewer screen.
class NetworkRequestViewerVM {
  /// Storage used to read and clear tracked requests.
  final storageService = NetworkRequestService.instance.storageService;

  /// Event stream provider used to react to repeat actions.
  final eventService = NetworkRequestService.instance.eventService;

  /// Active filter applied to grouped request lists.
  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());

  /// Filtered request groups keyed by endpoint path.
  final ValueNotifier<List<List<NetworkRequest>>> filteredRequestsNotifier =
      ValueNotifier([]);

  /// Currently selected base URL shown in the viewer.
  final ValueNotifier<String> selectedBaseUrl = ValueNotifier('');

  Timer? _debounce;
  late final StreamSubscription _repeatRequestSubscription;

  /// Creates a [NetworkRequestViewerVM] instance.
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

  /// Releases resources held by this instance.
  void dispose() {
    filterNotifier.dispose();
    filteredRequestsNotifier.dispose();
    _debounce?.cancel();
    _repeatRequestSubscription.cancel();
  }

  /// Updates the search query with a short debounce.
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final current = filterNotifier.value;
      if (current.searchQuery != query) {
        filterNotifier.value = current.copy(searchQuery: query);
      }
    });
  }

  /// Replaces the active filter and triggers a refresh.
  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
  }

  /// Clears filter.
  void clearFilter() {
    filterNotifier.value = NetworkRequestFilter();
  }

  /// Clears search text.
  void clearSearchText() {
    filterNotifier.value = filterNotifier.value.copy(searchQuery: '');
  }

  /// Clears specific filter.
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

  /// Clears requests list.
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
