import 'package:dio/dio.dart';

import '../../network_tracker.dart';
import '../model/network_request.dart';
import 'network_request_service.dart';

class NetworkRepeatRequestService {
  static final NetworkRepeatRequestService _instance =
      NetworkRepeatRequestService._internal();

  factory NetworkRepeatRequestService() => _instance;

  NetworkRepeatRequestService._internal();

  Dio? _customDio;

  /// Allows the user to provide their own Dio instance.
  /// This instance will be used when repeating requests.
  void setCustomDio(Dio dio) {
    _customDio = dio;
  }

  /// Returns all captured requests grouped by path.
  List<NetworkRequest> get repeatableRequests {
    final storage = NetworkRequestService.instance.storageService;
    final Map<String, NetworkRequest> uniqueRequests = {};

    final paths = storage.getTrackedPaths();

    for (final path in paths) {
      final requests = storage.getRequestsByPath(path);
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
    final dio = _customDio ??
        Dio(BaseOptions(
            baseUrl: NetworkRequestService.instance.storageService.baseUrl));
    final isInterceptorAlreadyAdded =
        dio.interceptors.any((i) => i is NetworkTrackerInterceptor);

    if (!isInterceptorAlreadyAdded) {
      dio.interceptors.add(NetworkTrackerInterceptor());
    }

    dio
        .request(
      request.path,
      data: request.requestData,
      options: Options(
        method: request.method.value,
        headers: request.headers,
      ),
      queryParameters: request.queryParameters,
    )
        .then((_) {
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    }).catchError((e) {
      NetworkRequestService.instance.eventService.onRepeatRequestDone.add(null);
    });
  }
}
