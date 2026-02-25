import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:network_tracker/src/utils/extensions.dart';
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

  /// Base URL that the request was sent to.
  final String baseUrl;

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

  /// Whether the response for this request was modified/intercepted.
  bool? isModified;

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
    required this.baseUrl,
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
    this.isModified,
  });

  /// A human-readable name for the request, useful for display in UI or logs.
  ///
  /// Combines sanitized path, method, and timestamp.
  String get name => '${path.replaceAll('/', '')}_${method}_$startDate';

  /// Creates a copy of this [NetworkRequest] with optional overrides.
  NetworkRequest copyWith({
    String? id,
    String? path,
    String? baseUrl,
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
    bool? isModified,
  }) {
    return NetworkRequest(
      id: id ?? this.id,
      path: path ?? this.path,
      baseUrl: baseUrl ?? this.baseUrl,
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
      isModified: isModified ?? this.isModified,
    );
  }

  /// Converts the request to a simplified map representation,
  /// useful for exporting or debugging.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'baseUrl': baseUrl,
      'method': method.value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'headers': jsonEncode(headers),
      'requestData': jsonEncode(requestData),
      'queryParameters': jsonEncode(queryParameters),
      'status': status.name,
      'responseData': jsonEncode(responseData),
      'statusCode': statusCode,
      'responseHeaders': jsonEncode(responseHeaders),
      'dioError': dioError?.dioExceptionToJsonString(),
      'requestSizeBytes': requestSizeBytes,
      'responseSizeBytes': responseSizeBytes,
      'isRepeated': isRepeated == true ? 1 : 0,
      'isModified': isModified == true ? 1 : 0,
    };
  }

  /// Deserializes a [NetworkRequest] from persisted JSON data.
  static NetworkRequest fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? tryDecodeMap(String? source) {
      if (source == null) return null;
      try {
        final decoded = jsonDecode(source);
        return decoded is Map ? decoded.cast<String, dynamic>() : null;
      } catch (_) {
        return null;
      }
    }

    dynamic tryDecodeAny(String? source) {
      if (source == null) return null;
      try {
        return jsonDecode(source);
      } catch (_) {
        return null;
      }
    }

    return NetworkRequest(
      id: json['id'],
      path: json['path'],
      baseUrl: json['baseUrl'],
      method: NetworkRequestMethod.fromString(json['method']),
      startDate: DateTime.parse(json['startDate']),
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      headers: tryDecodeMap(json['headers']),
      requestData: tryDecodeAny(json['requestData']),
      queryParameters: tryDecodeMap(json['queryParameters']),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.failed,
      ),
      responseData: tryDecodeAny(json['responseData']),
      statusCode: json['statusCode'],
      responseHeaders: tryDecodeMap(json['responseHeaders']),
      dioError: DioExceptionExt.fromJsonString(json['dioError']),
      requestSizeBytes: json['requestSizeBytes'],
      responseSizeBytes: json['responseSizeBytes'],
      isRepeated: json['isRepeated'] == 1,
      isModified: json['isModified'] == 1,
    );
  }
}

/// CurlExporter extension.
extension CurlExporter on NetworkRequest {
  /// Converts this request into an equivalent `curl` command.
  String toCurl() {
    final buffer = StringBuffer();

    final methodUpper = method.name.toUpperCase();
    final queryString = _buildQueryString(queryParameters);
    final fullUrl = '${baseUrl.trim().replaceAll(RegExp(r'/+$'), '')}'
        '/${path.trim().replaceAll(RegExp(r'^/+'), '')}'
        '$queryString';

    buffer.write('curl -X $methodUpper "$fullUrl"');

    // Headers
    if (headers != null && headers!.isNotEmpty) {
      headers!.forEach((key, value) {
        if (value != null) {
          buffer.write(
              ' \\\n  -H "${_escape(key)}: ${_escape(value.toString())}"');
        }
      });
    }

    // Request body
    if (requestData != null && methodUpper != 'GET') {
      try {
        final encoded = jsonEncode(requestData);
        buffer.write(' \\\n  -d \'$encoded\'');
      } catch (_) {
        // Fallback to .toString() if not JSON serializable
        buffer.write(' \\\n  -d "${_escape(requestData.toString())}"');
      }
    }

    return buffer.toString();
  }

  String _escape(String input) {
    return input.replaceAll('"', r'\"');
  }

  String _buildQueryString(Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) return '';

    final query = queryParams.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
        .join('&');

    return '?$query';
  }
}
