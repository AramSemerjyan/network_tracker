import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:network_tracker/src/services/speed_test/speet_test_file.dart';

/// Interface for implementing a network speed test service.
///
/// Provides access to a test file and a method to measure download speed.
abstract class NetworkSpeedTestServiceInterface {
  /// Measures download speed and returns a human-readable string (e.g., "23.45 Mbps").
  Future<String> testDownloadSpeed(SpeedTestFile file);
}

/// Default implementation of [NetworkSpeedTestServiceInterface] using Dio.
///
/// Downloads a known large file and calculates the download speed in megabits per second (Mbps).
class NetworkSpeedTestService implements NetworkSpeedTestServiceInterface {
  /// Dio instance used to perform the download. Can be injected for testing or customization.
  final Dio _dio;

  /// Creates a new [NetworkSpeedTestService] with an optional custom Dio instance.
  NetworkSpeedTestService({Dio? dio}) : _dio = dio ?? _createDio();

  /// Creates a Dio instance with proper SSL configuration for speed tests.
  static Dio _createDio() {
    final dio = Dio();
    
    // Configure SSL certificate handling for Android
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow certificates from known speed test servers
        final allowedHosts = [
          'speed.hetzner.de',
          'proof.ovh.net',
          'speedtest.tele2.net',
        ];
        return allowedHosts.any((allowedHost) => host.contains(allowedHost));
      };
      return client;
    };
    
    return dio;
  }

  /// Downloads the [testFile] and calculates download speed based on elapsed time.
  ///
  /// Returns a human-readable string representing the speed (e.g., "12.87 Mbps").
  /// Throws an [HttpException] if the file fails to download or if the response is invalid.
  @override
  Future<String> testDownloadSpeed(SpeedTestFile file) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get<List<int>>(
        file.urlString,
        options: Options(responseType: ResponseType.bytes),
      );

      stopwatch.stop();

      final data = response.data;
      if (data == null || response.statusCode != 200) {
        throw HttpException('Failed to download test file');
      }

      final readableSpeed = _formatNetworkSpeed(data.length, stopwatch.elapsed);

      if (kDebugMode) {
        print('Speed: $readableSpeed');
      }

      return readableSpeed;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// Converts the number of downloaded bytes and elapsed time into a readable speed string.
  ///
  /// Automatically scales the result to bps, Kbps, Mbps, or Gbps.
  String _formatNetworkSpeed(int bytes, Duration elapsed) {
    final seconds = elapsed.inMilliseconds / 1000;
    if (seconds == 0) return '0 bps';

    final bitsPerSecond = (bytes * 8) / seconds;

    if (bitsPerSecond < 1000) {
      return '${bitsPerSecond.toStringAsFixed(0)} bps';
    } else if (bitsPerSecond < 1000000) {
      return '${(bitsPerSecond / 1000).toStringAsFixed(2)} Kbps';
    } else if (bitsPerSecond < 1000000000) {
      return '${(bitsPerSecond / 1000000).toStringAsFixed(2)} Mbps';
    } else {
      return '${(bitsPerSecond / 1000000000).toStringAsFixed(2)} Gbps';
    }
  }
}
