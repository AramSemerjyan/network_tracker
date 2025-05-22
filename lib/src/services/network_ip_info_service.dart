import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class NetworkIPInfoServiceInterface {
  Future<String?> fetchExternalIP();
  Future<String?> fetchLocalIP();
}

class NetworkIPInfoService implements NetworkIPInfoServiceInterface {
  @override
  Future<String?> fetchExternalIP() async {
    try {
      final response = await Dio().get<String>(
        'https://api.ipify.org',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return response.data?.trim();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting external IP: $e');
      }
    }
    return null;
  }

  @override
  Future<String?> fetchLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting local IP: $e');
      }
    }
    return null;
  }
}
