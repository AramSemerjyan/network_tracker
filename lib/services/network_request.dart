import 'package:dio/dio.dart';

import 'request_status.dart';

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
  final String method;

  /// The time when the request was initiated.
  final DateTime timestamp;

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

  /// A string describing any error that occurred.
  String? error;

  /// The total execution time of the request, computed as a timestamp delta.
  DateTime? execTime;

  /// The raw [DioException], if available.
  DioException? dioError;

  /// Creates a new [NetworkRequest] instance.
  NetworkRequest({
    required this.id,
    required this.path,
    required this.method,
    required this.timestamp,
    this.headers,
    this.requestData,
    this.queryParameters,
    this.status = RequestStatus.pending,
    this.responseData,
    this.statusCode,
    this.responseHeaders,
    this.error,
    this.execTime,
    this.dioError,
  });

  /// Converts the request to a simplified map representation,
  /// useful for exporting or debugging.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'method': method,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'statusCode': statusCode,
      'requestData': requestData,
      'responseData': responseData,
      'error': error,
    };
  }

  /// A human-readable name for the request, useful for display in UI or logs.
  ///
  /// Combines sanitized path, method, and timestamp.
  String get name => '${path.replaceAll('/', '')}_${method}_$timestamp';
}
