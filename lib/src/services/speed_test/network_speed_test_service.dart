import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_tracker/src/services/speed_test/speet_test_file.dart';

/// Interface for implementing a network speed test service.
///
/// Provides access to a test file and a method to measure download speed.
abstract class NetworkSpeedTestServiceInterface {
  /// The file used for measuring download speed.
  SpeedTestFile get testFile;

  /// Measures download speed and returns a human-readable string (e.g., "23.45 Mbps").
  Future<String> testDownloadSpeed();
}

/// Default implementation of [NetworkSpeedTestServiceInterface] using Dio.
///
/// Downloads a known large file and calculates the download speed in megabits per second (Mbps).
class NetworkSpeedTestService implements NetworkSpeedTestServiceInterface {
  /// The file used for speed testing. Defaults to a ~70MB ZIP file.
  @override
  final SpeedTestFile testFile = SpeedTestFile.zip70Mb();

  /// Dio instance used to perform the download. Can be injected for testing or customization.
  final Dio _dio;

  /// Creates a new [NetworkSpeedTestService] with an optional custom Dio instance.
  NetworkSpeedTestService({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads the [testFile] and calculates download speed based on elapsed time.
  ///
  /// Returns a human-readable string representing the speed (e.g., "12.87 Mbps").
  /// Throws an [HttpException] if the file fails to download or if the response is invalid.
  @override
  Future<String> testDownloadSpeed() async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get<List<int>>(
        testFile.urlString,
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
    } else if (bitsPerSecond < 1_000_000) {
      return '${(bitsPerSecond / 1000).toStringAsFixed(2)} Kbps';
    } else if (bitsPerSecond < 1_000_000_000) {
      return '${(bitsPerSecond / 1_000_000).toStringAsFixed(2)} Mbps';
    } else {
      return '${(bitsPerSecond / 1_000_000_000).toStringAsFixed(2)} Gbps';
    }
  }
}
