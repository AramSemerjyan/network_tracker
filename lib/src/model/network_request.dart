import 'package:dio/dio.dart';
import 'package:network_tracker/src/utils/utils.dart';

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

  /// The size of the request payload in bytes.
  ///
  /// This value is computed based on the serialized body before sending.
  int? requestSizeBytes;

  /// A human-readable string representation of [requestSizeBytes],
  /// e.g. "512 bytes", "1.2Kb", "3Mb".
  String get requestSizeString => Utils.formatBytes(requestSizeBytes);

  /// The size of the response payload in bytes.
  ///
  /// This value is computed after receiving the response body.
  int? responseSizeBytes;

  /// A human-readable string representation of [responseSizeBytes],
  /// e.g. "1Kb", "4.3Mb".
  String get responseSizeString => Utils.formatBytes(responseSizeBytes);

  /// Indicates whether this request is a repeated (manually re-sent) request.
  ///
  /// Useful for distinguishing between original requests and user-triggered retries.
  bool? isRepeated;

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
    this.requestSizeBytes,
    this.responseSizeBytes,
    this.isRepeated,
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
      'requestSize': requestSizeBytes,
      'responseSize': responseSizeBytes,
      'isRepeated': isRepeated,
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
    int? requestSize,
    int? responseSize,
    bool? isRepeated,
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
      requestSizeBytes: requestSize ?? requestSizeBytes,
      responseSizeBytes: responseSize ?? responseSizeBytes,
      isRepeated: isRepeated ?? this.isRepeated,
    );
  }
}
