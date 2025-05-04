import 'package:flutter/cupertino.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';

class RequestDetailsScreenVM {
  final List<NetworkRequest> _requests;
  ValueNotifier<List<NetworkRequest>> requestsNotifier = ValueNotifier([]);
  final ValueNotifier<NetworkRequestFilter> filterNotifier =
      ValueNotifier(NetworkRequestFilter());

  RequestDetailsScreenVM(this._requests) {
    requestsNotifier.value = _requests;
    filterNotifier.addListener(_updateList);
  }

  void dispose() {
    requestsNotifier.dispose();
    filterNotifier.dispose();
  }

  void onFilterChanged(NetworkRequestFilter filter) {
    filterNotifier.value = filter;
  }

  void clearFilter() {
    filterNotifier.value = NetworkRequestFilter();
  }

  void repeatRequest(NetworkRequest request) {
    NetworkRequestService.instance.repeatRequestService.repeat(request);
  }

  void _updateList() {
    final filter = filterNotifier.value;
    List<NetworkRequest> requests = _requests;

    if (filter.method != null) {
      requests = requests.where((r) => r.method == filter.method).toList();
    }

    if (filter.status != null) {
      requests = requests.where((r) => r.status == filter.status).toList();
    }

    requestsNotifier.value = requests;
  }
}
