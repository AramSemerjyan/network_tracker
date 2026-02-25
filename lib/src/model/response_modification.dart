import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request_method.dart';

/// Overrides that can be applied to an intercepted response.
class ResponseModification {
  /// Optional status code to replace the original response status code.
  final int? statusCode;

  /// Optional response payload to replace the original response body.
  final dynamic responseData;

  /// Optional headers to merge into the response.
  final Map<String, String>? headers;

  /// Optional artificial delay before the modified response is delivered.
  final Duration? delay;

  /// Creates a [ResponseModification] instance.
  const ResponseModification({
    this.statusCode,
    this.responseData,
    this.headers,
    this.delay,
  });

  /// Returns the resulting status code after applying this modification.
  int? effectiveStatusCode(Response<dynamic> response) {
    return statusCode ?? response.statusCode;
  }

  /// Whether the resulting status code represents a failed request.
  bool isFailure(Response<dynamic> response) {
    final code = effectiveStatusCode(response);
    return code != null && code >= 400;
  }

  /// Applies this modification to the provided Dio [response].
  Response<dynamic> applyTo(Response<dynamic> response) {
    final mergedHeaders = headers != null
        ? Headers.fromMap(
            headers!.map((key, value) => MapEntry(key, [value])),
          )
        : response.headers;

    return Response<dynamic>(
      requestOptions: response.requestOptions,
      data: responseData ?? response.data,
      statusCode: statusCode ?? response.statusCode,
      statusMessage: response.statusMessage,
      headers: mergedHeaders,
      extra: response.extra,
      redirects: response.redirects,
      isRedirect: response.isRedirect,
    );
  }
}

/// Response modification keyed by endpoint identity.
class ResponseModificationEntry {
  /// Base URL of the endpoint.
  final String baseUrl;

  /// Path of the endpoint.
  final String path;

  /// HTTP method of the endpoint.
  final NetworkRequestMethod method;

  /// Active response override for this endpoint.
  final ResponseModification modification;

  /// Creates a [ResponseModificationEntry] instance.
  const ResponseModificationEntry({
    required this.baseUrl,
    required this.path,
    required this.method,
    required this.modification,
  });
}
