import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interface for implementing a network information service.
///
/// Provides methods to fetch both external (public) and local (private) IP addresses.
abstract class NetworkInfoServiceInterface {
  /// Fetches external network information including public IP and location data.
  ///
  /// Returns a map containing network details such as:
  /// - `query`: Public IP address
  /// - `country`: Country name
  /// - `city`: City name
  /// - `isp`: Internet service provider
  /// - And other location-based information
  ///
  /// Returns `null` if the request fails or times out.
  Future<Map<String, dynamic>?> fetchExternalInfo();

  /// Fetches the local IP address of the device on the current network.
  ///
  /// Returns the first non-loopback IPv4 address found on available network interfaces.
  /// Excludes link-local addresses (169.254.x.x).
  ///
  /// Returns `null` if no suitable IP address is found or if an error occurs.
  Future<String?> fetchLocalIP();
}

/// Default implementation of [NetworkInfoServiceInterface].
///
/// Uses ip-api.com to fetch external network information and system network
/// interfaces to determine the local IP address.
class NetworkInfoService implements NetworkInfoServiceInterface {
  /// Fetches external network information from ip-api.com.
  ///
  /// Makes an HTTP GET request to retrieve geolocation and ISP data
  /// associated with the device's public IP address.
  ///
  /// Returns a map with network details on success, or `null` on failure.
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

  /// Fetches the local IPv4 address of the device.
  ///
  /// Iterates through all network interfaces to find the first active,
  /// non-loopback IPv4 address. This is typically the device's address
  /// on the local network (e.g., 192.168.x.x or 10.x.x.x).
  ///
  /// Returns the IP address as a string, or `null` if none is found.
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
