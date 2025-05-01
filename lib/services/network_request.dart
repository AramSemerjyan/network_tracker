import 'package:dio/dio.dart';

import 'request_status.dart';

class NetworkRequest {
  final String id;
  final String path;
  final String method;
  final DateTime timestamp;
  final Map<String, dynamic>? headers;
  final dynamic requestData;
  final Map<String, dynamic>? queryParameters;

  RequestStatus status;
  dynamic responseData;
  int? statusCode;
  Map<String, dynamic>? responseHeaders;
  String? error;
  DateTime? execTime;
  DioException? dioError;

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

  String get name => '${path.replaceAll('/', '')}_${method}_$timestamp';
}
