import 'package:dio/dio.dart';
import 'package:network_tracker/src/utils/utils.dart';

import '../../model/network_request.dart';
import '../../model/network_request_filter.dart';
import '../../model/network_request_storage_interface.dart';
import '../request_status.dart';

/// A concrete implementation of [NetworkRequestStorageInterface] that stores
/// network requests in memory and allows filtering/grouping.
class NetworkRequestLocalStorage implements NetworkRequestStorageInterface {
  /// Internal map storing requests grouped by request path.
  final Map<String, Map<String, List<NetworkRequest>>> _requests = {};

  @override
  Future<List<String>> getUrls() async {
    return _requests.keys.toList();
  }

  @override

  /// Adds a new [NetworkRequest] to the internal map under its path.
  ///
  /// If the path is not already tracked, a new list will be created.
  Future<void> addRequest(NetworkRequest request) async {
    final requests = _requests[request.baseUrl] ?? {};

    requests.putIfAbsent(request.path, () => []).add(request);
    _requests[request.baseUrl] = requests;
  }

  @override

  /// Updates an existing request identified by [id].
  ///
  /// If found, updates the request with the new [status], [responseData],
  /// [statusCode], [responseHeaders], [error], and calculates its execution time.
  Future<void> updateRequest(
    String id, {
    required RequestOptions requestOptions,
    Response? response,
    RequestStatus? status,
    DateTime? endDate,
    DioException? dioError,
    bool? isModified,
  }) async {
    final requests = _requests[requestOptions.baseUrl] ?? {};

    for (final list in requests.values) {
      final index = list.indexWhere((r) => r.id == id);
      if (index != -1) {
        final request = list[index];
        list[index] = request.copyWith(
          status: status,
          responseData: response?.data,
          statusCode: response?.statusCode,
          responseHeaders: response?.headers.map,
          endDate: endDate,
          dioError: dioError,
          responseSize: Utils.estimateSize(response?.data),
          isModified: isModified ?? request.isModified,
        );
        return;
      }
    }
  }

  @override

  /// Retrieves all requests made to a specific [path], sorted by most recent first.
  ///
  /// Returns an empty list if no requests exist for the given path.
  Future<List<NetworkRequest>> getRequestsByPath(String path, String baseUrl) {
    final requestsByUrl = _requests[baseUrl] ?? {};

    final requests = List<NetworkRequest>.from(requestsByUrl[path] ?? []);
    requests.sort((a, b) => b.startDate.compareTo(a.startDate));
    return Future.value(requests);
  }

  @override

  /// Returns all tracked request paths sorted by latest request time (descending).
  Future<List<String>> getTrackedPaths(String baseUrl) {
    final requests = _requests[baseUrl] ?? {};

    final paths = requests.entries
        .map((e) => MapEntry(e.key, e.value.last.startDate))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Future.value(paths.map((e) => e.key).toList());
  }

  @override

  /// Retrieves and filters requests by method, status, and search query.
  ///
  /// Groups requests by path and returns only those that match the [filter].
  /// Each group contains all matching requests for a single path.
  Future<List<List<NetworkRequest>>> getFilteredGroups(
      NetworkRequestFilter filter, String baseUrl) async {
    final List<List<NetworkRequest>> result = [];
    final paths = await getTrackedPaths(baseUrl);

    for (final path in paths) {
      var requests = await getRequestsByPath(path, baseUrl);

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

  @override
  Future<void> clear() async {
    _requests.clear();
  }
}
