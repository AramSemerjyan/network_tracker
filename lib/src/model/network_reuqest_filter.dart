import '../services/request_status.dart';
import 'network_request_method.dart';

class NetworkRequestFilter {
  final String searchQuery;
  final NetworkRequestMethod? method;
  final RequestStatus? status;

  NetworkRequestFilter({
    this.searchQuery = '',
    this.method,
    this.status,
  });

  NetworkRequestFilter copy({
    String? searchQuery,
    NetworkRequestMethod? method,
    RequestStatus? status,
  }) {
    return NetworkRequestFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      method: method ?? this.method,
      status: status ?? this.status,
    );
  }
}
