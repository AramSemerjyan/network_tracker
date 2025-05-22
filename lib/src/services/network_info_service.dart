import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class NetworkInfoServiceInterface {
  Future<Map<String, dynamic>?> fetchExternalInfo();
  Future<String?> fetchLocalIP();
}

class NetworkInfoService implements NetworkInfoServiceInterface {
  @override
  Future<Map<String, dynamic>?> fetchExternalInfo() async {
    try {
      final response = await Dio().get('http://ip-api.com/json');
      if (response.statusCode == 200) {
        return response.data;
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
