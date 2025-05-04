import 'package:dio/dio.dart';

import '../services/request_status.dart';
import 'network_request_method.dart';

/// A model representing a tracked network request and its metadata.
///
/// This class holds all relevant information about an HTTP request, including
/// request method, path, timestamp, headers, payload, response status, response
/// data, and any errors that occurred during the request lifecycle.
///
/// It is used by the `NetworkTrackerInterceptor` to record and manage tracked
/// requests via `NetworkRequestStorage`.
class NetworkRequest {
  /// A unique identifier for this request (typically a UUID).
  final String id;

  /// The request path, e.g. `/users/1`.
  final String path;

  /// The HTTP method, e.g. `GET`, `POST`, `PUT`, etc.
  final NetworkRequestMethod method;

  /// The time when the request was initiated.
  final DateTime startDate;

  /// The time when the request was finished.
  final DateTime? endDate;

  /// The request headers.
  final Map<String, dynamic>? headers;

  /// The body of the request (can be any type).
  final dynamic requestData;

  /// Optional query parameters sent with the request.
  final Map<String, dynamic>? queryParameters;

  /// Current status of the request, e.g. pending, sent, completed, failed.
  RequestStatus status;

  /// The body of the response (can be any type).
  dynamic responseData;

  /// The HTTP status code from the response.
  int? statusCode;

  /// The response headers returned by the server.
  Map<String, dynamic>? responseHeaders;

  /// The raw [DioException], if available.
  DioException? dioError;

  /// The total execution time of the request, computed as a timestamp delta.
  Duration? get duration {
    final endDate = this.endDate;

    if (endDate != null) return endDate.difference(startDate);

    return null;
  }

  /// Creates a new [NetworkRequest] instance.
  NetworkRequest({
    required this.id,
    required this.path,
    required this.method,
    required this.startDate,
    this.endDate,
    this.headers,
    this.requestData,
    this.queryParameters,
    this.status = RequestStatus.pending,
    this.responseData,
    this.statusCode,
    this.responseHeaders,
    this.dioError,
  });

  /// Converts the request to a simplified map representation,
  /// useful for exporting or debugging.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'method': method,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'statusCode': statusCode,
      'requestData': requestData,
      'responseData': responseData,
      'duration': duration,
      'dioError': dioError.toString(),
    };
  }

  /// A human-readable name for the request, useful for display in UI or logs.
  ///
  /// Combines sanitized path, method, and timestamp.
  String get name => '${path.replaceAll('/', '')}_${method}_$startDate';

  /// Creates a copy of this [NetworkRequest] with optional overrides.
  NetworkRequest copyWith({
    String? id,
    String? path,
    NetworkRequestMethod? method,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? headers,
    dynamic requestData,
    Map<String, dynamic>? queryParameters,
    RequestStatus? status,
    dynamic responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    DateTime? execTime,
    DioException? dioError,
  }) {
    return NetworkRequest(
      id: id ?? this.id,
      path: path ?? this.path,
      method: method ?? this.method,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      headers: headers ?? this.headers,
      requestData: requestData ?? this.requestData,
      queryParameters: queryParameters ?? this.queryParameters,
      status: status ?? this.status,
      responseData: responseData ?? this.responseData,
      statusCode: statusCode ?? this.statusCode,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      dioError: dioError ?? this.dioError,
    );
  }
}
