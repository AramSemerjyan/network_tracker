import 'package:dio/dio.dart';

abstract class NetworkExternalInfoServiceInterface {
  Future<String?> fetchExternalIp();
}

class NetworkExternalInfoService
    implements NetworkExternalInfoServiceInterface {
  @override
  Future<String?> fetchExternalIp() async {
    try {
      final response = await Dio().get<String>(
        'https://api.ipify.org',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return response.data?.trim();
      }
    } catch (_) {}
    return null;
  }
}
