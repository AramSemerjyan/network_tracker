import '../services/request_status.dart';
import 'network_request_method.dart';

class NetworkRequestFilter {
  final String searchQuery;
  final NetworkRequestMethod? method;
  final RequestStatus? status;
  final bool? isRepeated;

  NetworkRequestFilter({
    this.searchQuery = '',
    this.method,
    this.status,
    this.isRepeated,
  });

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
