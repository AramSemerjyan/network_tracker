import 'dart:convert';

import 'package:dio/dio.dart';

/// DioExceptionExt extension.
extension DioExceptionExt on DioException {
  /// Converts this [DioException] to a JSON string representation.
  String dioExceptionToJsonString() {
    return jsonEncode(_dioExceptionToMap());
  }

  /// Constructs a [DioException] from a JSON string.
  static DioException? fromJsonString(String? json) {
    if (json == null) return null;

    final Map<String, dynamic> map = jsonDecode(json);
    return _mapToDioException(map);
  }

  /// Converts this [DioException] to a `Map<String, dynamic>` for serialization.
  Map<String, dynamic> _dioExceptionToMap() {
    return {
      'type': type.name,
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace.toString(),
      'responseStatusCode': response?.statusCode,
      'responseData': response?.data?.toString(),
      'responseHeaders': response?.headers.map.toString(),
      'requestPath': requestOptions.path,
      'requestMethod': requestOptions.method,
    };
  }

  /// Constructs a [DioException] from a map.
  static DioException _mapToDioException(Map<String, dynamic> map) {
    return DioException(
      requestOptions: RequestOptions(
        path: map['requestPath'] ?? '',
        method: map['requestMethod'] ?? 'GET',
      ),
      response: Response(
        requestOptions: RequestOptions(
          path: map['requestPath'] ?? '',
        ),
        statusCode: map['responseStatusCode'],
        data: map['responseData'],
        headers: Headers.fromMap({}), // Simplified, can be enhanced
      ),
      error: map['error'],
      message: map['message'],
      type: DioExceptionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => DioExceptionType.unknown,
      ),
    );
  }
}
