import 'package:dio/dio.dart';
import 'package:network_tracker/src/services/request_status.dart';

import 'network_request.dart';
import 'network_request_filter.dart';

/// Interface defining the contract for storing and retrieving network requests.
///
/// Implementations of this interface provide different storage strategies
/// (e.g., in-memory, SQLite, remote storage) for persisting captured network
/// requests and their responses.
///
/// Two built-in implementations are available:
/// - [NetworkRequestLocalStorage]: In-memory storage (data lost on app restart)
/// - [NetworkRequestPersistentStorage]: SQLite storage (persists across restarts)
///
/// Example implementation:
/// ```dart
/// class CustomStorage implements NetworkRequestStorageInterface {
///   @override
///   Future<void> addRequest(NetworkRequest request) async {
///     // Your custom storage logic
///   }
///   // ... implement other methods
/// }
/// ```
abstract class NetworkRequestStorageInterface {
  /// Adds a new network request to storage.
  ///
  /// This is typically called when a request is initiated (before receiving a response).
  /// The request contains the HTTP method, URL, headers, body, and timestamp.
  ///
  /// The [request] should have a unique ID generated before calling this method.
  Future<void> addRequest(NetworkRequest request);

  /// Updates an existing request with response data and completion status.
  ///
  /// Called when a request completes (successfully or with an error) to update
  /// the stored request with response information.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the request to update
  /// - [response]: The HTTP response received (if successful)
  /// - [requestOptions]: Updated request options from Dio
  /// - [status]: The final status of the request (success, error, etc.)
  /// - [endDate]: Timestamp when the request completed
  /// - [dioError]: Error information if the request failed
  Future<void> updateRequest(
    String id, {
    Response? response,
    required RequestOptions requestOptions,
    RequestStatus? status,
    DateTime? endDate,
    DioException? dioError,
    bool? isModified,
  });

  /// Retrieves all requests made to a specific endpoint path.
  ///
  /// Returns requests matching the given [path] and [baseUrl], sorted by
  /// most recent first. This is useful for viewing the history of requests
  /// to a particular API endpoint.
  ///
  /// Example:
  /// ```dart
  /// final requests = await storage.getRequestsByPath(
  ///   '/api/users',
  ///   'https://example.com',
  /// );
  /// ```
  Future<List<NetworkRequest>> getRequestsByPath(
    String path,
    String baseUrl,
  );

  /// Returns all unique API paths that have been tracked for a given base URL.
  ///
  /// Results are sorted by most recent activity. This is useful for displaying
  /// a list of all endpoints that have been accessed.
  ///
  /// Example:
  /// ```dart
  /// final paths = await storage.getTrackedPaths('https://api.example.com');
  /// // Result: ['/users', '/posts', '/comments']
  /// ```
  Future<List<String>> getTrackedPaths(String baseUrl);

  /// Retrieves requests filtered and grouped by path.
  ///
  /// Applies the provided [filter] criteria (status, method, search text, etc.)
  /// and returns results grouped by endpoint path. Each inner list contains
  /// all requests for a specific path that match the filter.
  ///
  /// Useful for displaying filtered requests organized by endpoint.
  ///
  /// Example:
  /// ```dart
  /// final filter = NetworkRequestFilter(
  ///   status: RequestStatus.error,
  ///   method: NetworkRequestMethod.post,
  /// );
  /// final groups = await storage.getFilteredGroups(filter, baseUrl);
  /// ```
  Future<List<List<NetworkRequest>>> getFilteredGroups(
    NetworkRequestFilter filter,
    String baseUrl,
  );

  /// Returns a list of all unique base URLs that have been tracked.
  ///
  /// This provides a list of all distinct servers/domains that the app
  /// has communicated with.
  ///
  /// Example:
  /// ```dart
  /// final urls = await storage.getUrls();
  /// // Result: ['https://api.example.com', 'https://cdn.example.com']
  /// ```
  Future<List<String>> getUrls();

  /// Removes all stored network requests from storage.
  ///
  /// This permanently deletes all tracked request data. Use with caution,
  /// especially with persistent storage implementations.
  ///
  /// Example:
  /// ```dart
  /// await storage.clear(); // All request history is deleted
  /// ```
  Future<void> clear();
}
