import 'package:dio/dio.dart';

import '../services/request_status.dart';
import 'network_request.dart';
import 'network_request_filter.dart';

/// An interface that defines the contract for storing and retrieving network requests.
abstract class NetworkRequestStorageInterface {
  /// The base URL used in tracked requests.
  String get baseUrl;

  /// Sets the base URL for tracked requests.
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
    DateTime? endDate,
    DioException? dioError,
    int? responseSize,
  });

  /// Retrieves all requests made to a specific [path], sorted by most recent first.
  List<NetworkRequest> getRequestsByPath(String path);

  /// Returns a list of all tracked paths sorted by most recent activity.
  List<String> getTrackedPaths();

  /// Returns a grouped list of filtered requests by path using [filter].
  List<List<NetworkRequest>> getFilteredGroups(NetworkRequestFilter filter);
}
