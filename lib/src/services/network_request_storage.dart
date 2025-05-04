import '../model/network_request.dart';
import 'request_status.dart';

/// An interface that defines the contract for storing and retrieving network requests.
abstract class NetworkRequestStorageInterface {
  /// The base URL used in tracked requests.
  String get baseUrl;

  void setBaseUrl(String baseUrl);

  /// Adds a new [NetworkRequest] to the storage.
  void addRequest(NetworkRequest request);

  /// Updates an existing request by [id] with optional response data and status.
  void updateRequest(
    String id, {
    RequestStatus? status,
    dynamic responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? error,
  });

  /// Retrieves all requests made to a specific [path], sorted by most recent first.
  List<NetworkRequest> getRequestsByPath(String path);

  /// Returns a list of all tracked paths sorted by most recent activity.
  List<String> getTrackedPaths();
}

/// Concrete implementation of [NetworkRequestStorageInterface] that stores and organizes
/// requests in memory by path and tracks their details.
class NetworkRequestStorage implements NetworkRequestStorageInterface {
  final List<NetworkRequest> _allRequests = [];
  final Map<String, List<NetworkRequest>> _requestsByPath = {};

  @override
  String baseUrl = '';

  @override
  void setBaseUrl(String baseUrl) {
    this.baseUrl = baseUrl;
  }

  /// Adds a new [NetworkRequest] to the internal list and organizes it by its path.
  @override
  void addRequest(NetworkRequest request) {
    _allRequests.add(request);
    _requestsByPath.putIfAbsent(request.path, () => []).add(request);
  }

  /// Updates an existing request identified by [id] with optional fields like [status],
  /// [responseData], [statusCode], [responseHeaders], and [error].
  ///
  /// Also calculates and stores the execution time.
  @override
  void updateRequest(
    String id, {
    RequestStatus? status,
    dynamic responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? error,
  }) {
    final request = _allRequests.firstWhere((r) => r.id == id);
    final now = DateTime.now();
    final execTime =
        now.millisecondsSinceEpoch - request.timestamp.millisecondsSinceEpoch;

    request
      ..status = status ?? request.status
      ..responseData = responseData ?? request.responseData
      ..statusCode = statusCode ?? request.statusCode
      ..responseHeaders = responseHeaders ?? request.responseHeaders
      ..error = error ?? request.error
      ..execTime = DateTime.fromMillisecondsSinceEpoch(execTime);
  }

  /// Returns a list of all requests made to the given [path],
  /// sorted by descending timestamp (most recent first).
  @override
  List<NetworkRequest> getRequestsByPath(String path) {
    final requests = _requestsByPath[path]?.toList() ?? [];
    requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return requests;
  }

  /// Returns a list of all paths that have been tracked,
  /// sorted by the timestamp of their most recent request (descending).
  @override
  List<String> getTrackedPaths() {
    final pathsWithTimestamps = _requestsByPath.entries.map((entry) {
      final latestRequest = entry.value.last;
      return MapEntry(entry.key, latestRequest.timestamp);
    }).toList();

    pathsWithTimestamps.sort((a, b) => b.value.compareTo(a.value));

    return pathsWithTimestamps.map((e) => e.key).toList();
  }
}
