import '../services/request_status.dart';
import 'network_request_method.dart';

/// A model representing the filters applied when viewing tracked network requests.
///
/// Supports filtering by:
/// - [searchQuery] — path-based keyword search
/// - [method] — specific HTTP method (e.g. GET, POST)
/// - [status] — request status (e.g. sent, completed, failed)
/// - [isRepeated] — whether to show only repeated requests
class NetworkRequestFilter {
  /// Free-text search query used to filter by request path.
  final String searchQuery;

  /// Optional HTTP method to filter by (e.g. GET, POST).
  final NetworkRequestMethod? method;

  /// Optional status filter (e.g. sent, completed, failed).
  final RequestStatus? status;

  /// Whether to filter for only repeated requests.
  final bool? isRepeated;

  /// Creates a new filter with optional search, method, status, and repeat settings.
  NetworkRequestFilter({
    this.searchQuery = '',
    this.method,
    this.status,
    this.isRepeated,
  });

  /// Returns a new [NetworkRequestFilter] with updated values.
  ///
  /// Any parameter passed to [copy] will override the current value.
  /// Use this method when modifying specific parts of the filter.
  NetworkRequestFilter copy({
    String? searchQuery,
    NetworkRequestMethod? method,
    RequestStatus? status,
    bool? repeatedOnly,
  }) {
    return NetworkRequestFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      method: method ?? this.method,
      status: status ?? this.status,
      isRepeated: repeatedOnly ?? isRepeated,
    );
  }
}
