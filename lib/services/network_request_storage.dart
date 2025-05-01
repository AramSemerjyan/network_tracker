import 'network_request.dart';
import 'request_status.dart';

abstract class NetworkRequestStorageInterface {
  String get baseUrl;

  void addRequest(NetworkRequest request);
  void updateRequest(
    String id, {
    RequestStatus? status,
    dynamic responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? error,
  });
  List<NetworkRequest> getRequestsByPath(String path);
  List<String> getTrackedPaths();
}

class NetworkRequestStorage implements NetworkRequestStorageInterface {
  final List<NetworkRequest> _allRequests = [];
  final Map<String, List<NetworkRequest>> _requestsByPath = {};

  @override
  String baseUrl = '';

  static NetworkRequestStorage? _instance;
  static NetworkRequestStorage get instance {
    return _instance ??= NetworkRequestStorage();
  }

  @override
  void addRequest(NetworkRequest request) {
    _allRequests.add(request);
    _requestsByPath.putIfAbsent(request.path, () => []).add(request);
  }

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

  @override
  List<NetworkRequest> getRequestsByPath(String path) {
    final requests = _requestsByPath[path]?.toList() ?? [];

    requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return requests;
  }

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
