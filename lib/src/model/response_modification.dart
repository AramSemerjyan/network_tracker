import 'package:dio/dio.dart';

class ResponseModification {
  final int? statusCode;
  final dynamic responseData;
  final Map<String, String>? headers;
  final Duration? delay;

  const ResponseModification({
    this.statusCode,
    this.responseData,
    this.headers,
    this.delay,
  });

  int? effectiveStatusCode(Response<dynamic> response) {
    return statusCode ?? response.statusCode;
  }

  bool isFailure(Response<dynamic> response) {
    final code = effectiveStatusCode(response);
    return code != null && code >= 400;
  }

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
