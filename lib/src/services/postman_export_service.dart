import 'dart:convert';

import '../model/network_request.dart';

/// Service for exporting network requests as Postman collections.
///
/// Converts a list of [NetworkRequest] objects into a Postman Collection v2.1 format
/// that can be imported directly into Postman for testing and sharing.
class PostmanExportService {
  /// Exports a list of [NetworkRequest] objects as a Postman Collection JSON string.
  ///
  /// Parameters:
  /// - [requests]: List of network requests to export
  /// - [collectionName]: Name of the Postman collection (typically project name)
  /// - [prettyPrint]: Whether to format the JSON output with indentation (default: true)
  ///
  /// Returns a JSON string that can be saved as a `.json` file and imported into Postman.
  static String exportToPostmanCollection({
    required List<NetworkRequest> requests,
    required String collectionName,
    bool prettyPrint = true,
  }) {
    final collection = _buildPostmanCollection(
      requests: requests,
      collectionName: collectionName,
    );
    return prettyPrint
        ? const JsonEncoder.withIndent('  ').convert(collection)
        : jsonEncode(collection);
  }

  /// Builds the Postman collection structure.
  static Map<String, dynamic> _buildPostmanCollection({
    required List<NetworkRequest> requests,
    required String collectionName,
  }) {
    return {
      'info': {
        '_postman_id': _generateUuid(),
        'name': collectionName,
        'description':
            'Exported from Network Tracker on ${DateTime.now().toIso8601String()}',
        'schema':
            'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
      },
      'item': requests.map(_buildPostmanItem).toList(),
    };
  }

  /// Converts a single [NetworkRequest] to a Postman item.
  static Map<String, dynamic> _buildPostmanItem(NetworkRequest request) {
    final fullUrl = _buildFullUrl(request);
    final parsedUrl = _parseUrl(fullUrl);

    return {
      'name': _generateRequestName(request),
      'request': {
        'method': request.method.name.toUpperCase(),
        'header': _buildHeaders(request.headers),
        'body': _buildBody(request),
        'url': parsedUrl,
        'description': _buildDescription(request),
      },
    };
  }

  /// Generates a descriptive name for the request.
  static String _generateRequestName(NetworkRequest request) {
    final method = request.method.name.toUpperCase();
    final path = request.path.isEmpty ? 'root' : request.path;
    return '$method $path';
  }

  /// Builds the full URL from base URL, path, and query parameters.
  static String _buildFullUrl(NetworkRequest request) {
    final baseUrl = request.baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final path = request.path.trim().replaceAll(RegExp(r'^/+'), '');
    final fullUrl = '$baseUrl/$path';

    if (request.queryParameters != null &&
        request.queryParameters!.isNotEmpty) {
      final query = request.queryParameters!.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
          .join('&');
      return '$fullUrl?$query';
    }

    return fullUrl;
  }

  /// Parses a URL string into Postman's URL object format.
  static Map<String, dynamic> _parseUrl(String urlString) {
    final uri = Uri.parse(urlString);

    return {
      'raw': urlString,
      'protocol': uri.scheme,
      'host': uri.host.split('.'),
      'path': uri.pathSegments,
      if (uri.hasQuery)
        'query': uri.queryParameters.entries
            .map((e) => {
                  'key': e.key,
                  'value': e.value,
                })
            .toList(),
    };
  }

  /// Converts request headers to Postman header format.
  static List<Map<String, dynamic>> _buildHeaders(
      Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return [];

    return headers.entries
        .where((e) => e.value != null)
        .map((e) => {
              'key': e.key,
              'value': e.value.toString(),
              'type': 'text',
            })
        .toList();
  }

  /// Builds the request body in Postman format.
  static Map<String, dynamic>? _buildBody(NetworkRequest request) {
    if (request.requestData == null) return null;

    final method = request.method.name.toUpperCase();
    if (method == 'GET' || method == 'HEAD') return null;

    // Determine content type
    final contentType =
        (request.headers?['content-type'] ?? request.headers?['Content-Type'])
            ?.toString()
            .toLowerCase();
    String rawString;
    Map<String, dynamic>? options;

    if (contentType == 'application/x-www-form-urlencoded' &&
        request.requestData is Map) {
      // Encode as URL-encoded string
      rawString = (request.requestData as Map)
          .entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key.toString())}=${Uri.encodeQueryComponent(e.value.toString())}')
          .join('&');
      options = null;
    } else if (request.requestData is Map || request.requestData is List) {
      // Encode as JSON string
      rawString = jsonEncode(request.requestData);
      options = {
        'raw': {
          'language': 'json',
        }
      };
    } else {
      rawString = request.requestData.toString();
      options = null;
    }

    final Map<String, dynamic> body = {
      'mode': 'raw',
      'raw': rawString,
    };
    if (options != null) {
      body['options'] = options;
    }
    return body;
  }

  /// Builds a description for the request including metadata.
  static String _buildDescription(NetworkRequest request) {
    final buffer = StringBuffer();

    buffer.writeln('**Request Details**');
    buffer.writeln('- Original Request ID: ${request.id}');
    buffer.writeln('- Timestamp: ${request.startDate.toIso8601String()}');

    if (request.duration != null) {
      buffer.writeln('- Duration: ${request.duration!.inMilliseconds}ms');
    }

    if (request.statusCode != null) {
      buffer.writeln('- Status Code: ${request.statusCode}');
    }

    if (request.requestSizeBytes != null) {
      buffer.writeln('- Request Size: ${request.requestSizeString}');
    }

    if (request.responseSizeBytes != null) {
      buffer.writeln('- Response Size: ${request.responseSizeString}');
    }

    if (request.isRepeated == true) {
      buffer.writeln('- This was a repeated/retried request');
    }

    return buffer.toString();
  }

  /// Generates a simple UUID for the collection.
  static String _generateUuid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return '$now-${now.hashCode.abs()}';
  }
}
