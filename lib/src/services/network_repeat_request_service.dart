import 'package:dio/dio.dart';

import '../../network_tracker.dart';
import '../model/network_request.dart';

class NetworkRepeatRequestService {
  static NetworkRepeatRequestService? _instance;

  static NetworkRepeatRequestService get instance {
    return _instance ??= NetworkRepeatRequestService._internal();
  }

  NetworkRepeatRequestService._internal();

  final Map<String, Dio> _clients = {};

  /// Allows the user to provide their own Dio instance.
  /// This instance will be used when repeating requests.
  void setCustomDio(Dio dio) {
    _clients[dio.options.baseUrl] = dio;
  }

  /// Returns all captured requests grouped by path.
  Future<List<NetworkRequest>> repeatableRequests(
      {required String baseUrl}) async {
    final storage = NetworkRequestService.instance.storageService;
    final Map<String, NetworkRequest> uniqueRequests = {};

    final paths = await storage.getTrackedPaths(baseUrl);

    for (final path in paths) {
      final requests = await storage.getRequestsByPath(path, baseUrl);
      for (final request in requests) {
        final key = '${request.method.value}_${request.path}';
        if (!uniqueRequests.containsKey(key)) {
          uniqueRequests[key] = request;
        }
      }
    }

    return uniqueRequests.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Repeats the provided request using Dio.
  /// If a custom Dio is provided, it will be used; otherwise a default one is used.
  void repeat(NetworkRequest request) async {
    request = request.copyWith(isRepeated: true);

    final dio =
        _clients[request.baseUrl] ?? Dio(BaseOptions(baseUrl: request.baseUrl));
    final isInterceptorAlreadyAdded =
        dio.interceptors.any((i) => i is NetworkTrackerInterceptor);

    if (!isInterceptorAlreadyAdded) {
      dio.interceptors.add(NetworkTrackerInterceptor());
    }

    final options = Options(
      method: request.method.value,
      headers: request.headers,
    );

    options.extra = {
      'is_repeated': request.isRepeated ?? false,
    };

    dio
        .request(
      request.path,
      data: request.requestData,
      options: options,
      queryParameters: request.queryParameters,
    )
        .then((_) {
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    }).catchError((e) {
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    });
  }
}
