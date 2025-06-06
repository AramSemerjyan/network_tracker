import 'package:dio/dio.dart';
import 'package:network_tracker/src/services/request_status.dart';

import 'network_request.dart';
import 'network_request_filter.dart';

/// An interface that defines the contract for storing and retrieving network requests.
abstract class NetworkRequestStorageInterface {
  /// Adds a new [NetworkRequest] to the storage.
  Future<void> addRequest(NetworkRequest request);

  /// Updates an existing request by [id] with optional response data and status.
  Future<void> updateRequest(
    String id, {
    Response? response,
    required RequestOptions requestOptions,
    RequestStatus? status,
    DateTime? endDate,
    DioException? dioError,
  });

  /// Retrieves all requests made to a specific [path], sorted by most recent first.
  Future<List<NetworkRequest>> getRequestsByPath(
    String path,
    String baseUrl,
  );

  /// Returns a list of all tracked paths sorted by most recent activity.
  Future<List<String>> getTrackedPaths(String baseUrl);

  /// Returns a grouped list of filtered requests by path using [filter].
  Future<List<List<NetworkRequest>>> getFilteredGroups(
    NetworkRequestFilter filter,
    String baseUrl,
  );

  Future<List<String>> getUrls();

  Future<void> clear();
}
