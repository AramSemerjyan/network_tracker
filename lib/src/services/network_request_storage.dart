import '../model/network_request.dart';
import '../model/network_request_filter.dart';
import '../model/network_request_storage_interface.dart';
import 'request_status.dart';

/// A concrete implementation of [NetworkRequestStorageInterface] that stores
/// network requests in memory and allows filtering/grouping.
class NetworkRequestStorage implements NetworkRequestStorageInterface {
  /// Internal map storing requests grouped by request path.
  final Map<String, List<NetworkRequest>> _requestsByPath = {};

  @override

  /// The base URL used in tracked requests.
  String baseUrl = '';

  @override

  /// Sets the [baseUrl] used for tracked network requests.
  void setBaseUrl(String baseUrl) {
    this.baseUrl = baseUrl;
  }

  @override

  /// Adds a new [NetworkRequest] to the internal map under its path.
  ///
  /// If the path is not already tracked, a new list will be created.
  void addRequest(NetworkRequest request) {
    _requestsByPath.putIfAbsent(request.path, () => []).add(request);
  }

  @override

  /// Updates an existing request identified by [id].
  ///
  /// If found, updates the request with the new [status], [responseData],
  /// [statusCode], [responseHeaders], [error], and calculates its execution time.
  void updateRequest(
    String id, {
    RequestStatus? status,
    dynamic responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? error,
    DateTime? endDate,
  }) {
    for (final list in _requestsByPath.values) {
      final index = list.indexWhere((r) => r.id == id);
      if (index != -1) {
        final request = list[index];
        list[index] = request.copyWith(
          status: status,
          responseData: responseData,
          statusCode: statusCode,
          responseHeaders: responseHeaders,
          error: error,
          endDate: endDate,
        );
        return;
      }
    }
  }

  @override

  /// Retrieves all requests made to a specific [path], sorted by most recent first.
  ///
  /// Returns an empty list if no requests exist for the given path.
  List<NetworkRequest> getRequestsByPath(String path) {
    final requests = List<NetworkRequest>.from(_requestsByPath[path] ?? []);
    requests.sort((a, b) => b.startDate.compareTo(a.startDate));
    return requests;
  }

  @override

  /// Returns all tracked request paths sorted by latest request time (descending).
  List<String> getTrackedPaths() {
    final paths = _requestsByPath.entries
        .map((e) => MapEntry(e.key, e.value.last.startDate))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return paths.map((e) => e.key).toList();
  }

  @override

  /// Retrieves and filters requests by method, status, and search query.
  ///
  /// Groups requests by path and returns only those that match the [filter].
  /// Each group contains all matching requests for a single path.
  List<List<NetworkRequest>> getFilteredGroups(NetworkRequestFilter filter) {
    final List<List<NetworkRequest>> result = [];

    for (final path in getTrackedPaths()) {
      var requests = getRequestsByPath(path);

      // Apply HTTP method filter
      if (filter.method != null) {
        requests = requests.where((r) => r.method == filter.method).toList();
      }

      // Apply request status filter
      if (filter.status != null) {
        requests = requests.where((r) => r.status == filter.status).toList();
      }

      // Apply search filter on path
      if (filter.searchQuery.isNotEmpty &&
          !path.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        continue;
      }

      if (requests.isNotEmpty) {
        result.add(requests);
      }
    }

    return result;
  }
}
