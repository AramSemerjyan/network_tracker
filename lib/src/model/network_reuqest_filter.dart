import '../services/request_status.dart';
import 'network_request_method.dart';

class NetworkRequestFilter {
  final NetworkRequestMethod? method;
  final RequestStatus? status;

  NetworkRequestFilter({
    this.method,
    this.status,
  });

  NetworkRequestFilter copy({
    NetworkRequestMethod? method,
    RequestStatus? status,
  }) {
    return NetworkRequestFilter(
      method: method ?? this.method,
      status: status ?? this.status,
    );
  }
}
