import 'package:dio/dio.dart';

import '../../network_tracker.dart';
import '../model/network_request.dart';

/// Service for repeating previously captured network requests.
///
/// This service allows you to replay HTTP requests that were previously
/// intercepted and stored by the NetworkTracker. It maintains custom Dio
/// instances per base URL and automatically injects the NetworkTrackerInterceptor
/// to track repeated requests.
///
/// Example usage:
/// ```dart
/// // Set a custom Dio instance (optional)
/// NetworkRepeatRequestService.instance.setCustomDio(myCustomDio);
///
/// // Get all repeatable requests for a base URL
/// final requests = await NetworkRepeatRequestService.instance
///     .repeatableRequests(baseUrl: 'https://api.example.com');
///
/// // Repeat a specific request
/// NetworkRepeatRequestService.instance.repeat(requests.first);
/// ```
class NetworkRepeatRequestService {
  static NetworkRepeatRequestService? _instance;

  /// Returns the singleton instance of [NetworkRepeatRequestService].
  static NetworkRepeatRequestService get instance {
    return _instance ??= NetworkRepeatRequestService._internal();
  }

  /// Private constructor for singleton pattern.
  NetworkRepeatRequestService._internal();

  /// Map of custom Dio clients keyed by their base URL.
  ///
  /// When repeating a request, if a custom client exists for the base URL,
  /// it will be used instead of creating a new Dio instance.
  final Map<String, Dio> clients = {};

  /// Registers a custom Dio instance for a specific base URL.
  ///
  /// When repeating requests, the service will use this Dio instance instead
  /// of creating a default one. This allows you to customize interceptors,
  /// timeouts, headers, and other Dio configurations.
  ///
  /// Example:
  /// ```dart
  /// final customDio = Dio(BaseOptions(
  ///   baseUrl: 'https://api.example.com',
  ///   connectTimeout: Duration(seconds: 10),
  /// ));
  /// NetworkRepeatRequestService.instance.setCustomDio(customDio);
  /// ```
  void setCustomDio(Dio dio) {
    clients[dio.options.baseUrl] = dio;
  }

  /// Retrieves all unique repeatable requests for a given base URL.
  ///
  /// Queries the storage service to fetch all tracked paths and their associated
  /// requests, then deduplicates them based on HTTP method and path combination.
  /// Results are sorted by start date in descending order (newest first).
  ///
  /// [baseUrl] The base URL to filter requests by (e.g., 'https://api.example.com').
  ///
  /// Returns a list of unique [NetworkRequest] objects that can be repeated.
  Future<List<NetworkRequest>> repeatableRequests(
      {required String baseUrl}) async {
    final storage = NetworkRequestService.instance.storageService;
    final Map<String, NetworkRequest> uniqueRequests = {};

    // Fetch all tracked paths for this base URL
    final paths = await storage.getTrackedPaths(baseUrl);

    // Collect unique requests (deduplicated by method + path)
    for (final path in paths) {
      final requests = await storage.getRequestsByPath(path, baseUrl);
      for (final request in requests) {
        final key = '${request.method.value}_${request.path}';
        if (!uniqueRequests.containsKey(key)) {
          uniqueRequests[key] = request;
        }
      }
    }

    // Sort by most recent first
    return uniqueRequests.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Repeats a previously captured network request.
  ///
  /// Creates a new HTTP request using the same method, path, headers, body,
  /// and query parameters as the original request. The request is marked as
  /// repeated and automatically tracked by the NetworkTrackerInterceptor.
  ///
  /// If a custom Dio instance has been registered via [setCustomDio] for the
  /// request's base URL, it will be used. Otherwise, a default Dio instance
  /// is created.
  ///
  /// The [NetworkTrackerInterceptor] is automatically added if not already present,
  /// ensuring the repeated request is captured and stored.
  ///
  /// Fires an event on [NetworkRequestService.instance.eventService.onRepeatRequestDone]
  /// when the request completes (either successfully or with an error).
  ///
  /// Example:
  /// ```dart
  /// final request = await storage.getRequestsByPath('/users', baseUrl).first;
  /// NetworkRepeatRequestService.instance.repeat(request);
  /// ```
  void repeat(NetworkRequest request) async {
    // Mark request as repeated
    request = request.copyWith(isRepeated: true);

    // Get or create Dio client for this base URL
    final dio =
        clients[request.baseUrl] ?? Dio(BaseOptions(baseUrl: request.baseUrl));

    // Ensure NetworkTrackerInterceptor is present
    final isInterceptorAlreadyAdded =
        dio.interceptors.any((i) => i is NetworkTrackerInterceptor);

    if (!isInterceptorAlreadyAdded) {
      dio.interceptors.add(NetworkTrackerInterceptor());
    }

    // Configure request options
    final options = Options(
      method: request.method.value,
      headers: request.headers,
    );

    // Add metadata to identify this as a repeated request
    options.extra = {
      'is_repeated': request.isRepeated ?? false,
    };

    // Execute the request
    dio
        .request(
      request.path,
      data: request.requestData,
      options: options,
      queryParameters: request.queryParameters,
    )
        .then((_) {
      // Notify listeners that the repeat request is complete
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    }).catchError((e) {
      // Notify listeners even on error
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    });
  }
}
