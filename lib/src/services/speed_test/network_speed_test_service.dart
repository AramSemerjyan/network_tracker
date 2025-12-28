import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:network_tracker/src/services/speed_test/speet_test_file.dart';

/// Interface for implementing a network speed test service.
///
/// Provides access to a test file and a method to measure download speed.
abstract class NetworkSpeedTestServiceInterface {
  /// Measures download speed by performing multiple test runs and returns the median speed.
  ///
  /// Performs multiple download iterations to account for network variability and
  /// returns a human-readable string representing the median speed (e.g., "23.45 Mbps").
  ///
  /// Using multiple runs improves accuracy by:
  /// - Filtering out temporary network congestion or spikes
  /// - Accounting for TCP slow-start overhead
  /// - Eliminating outliers caused by packet loss or route changes
  /// - Providing more consistent and reliable speed measurements
  ///
  /// A warmup request (HEAD) is performed first to establish DNS resolution
  /// and SSL connections, ensuring subsequent tests measure actual download speed
  /// rather than connection overhead.
  ///
  /// Parameters:
  /// - [file]: The test file to download for speed measurement
  /// - [iterations]: Number of test runs to perform (default: 3). More iterations
  ///   provide better accuracy but take longer to complete.
  /// - [onProgress]: Optional callback that receives download progress for each iteration:
  ///   - [received]: bytes downloaded so far
  ///   - [total]: total bytes to download (if known, otherwise -1)
  ///
  /// Returns a formatted string representing the median download speed.
  /// Throws [HttpException] if all test runs fail.
  Future<String> testDownloadSpeed(
    SpeedTestFile file, {
    int iterations = 3,
    void Function(int received, int total)? onProgress,
  });

  /// Stops any ongoing speed test.
  ///
  /// Cancels the current download operation if a test is in progress.
  /// This is safe to call even if no test is running.
  void stopTest();
}

/// Default implementation of [NetworkSpeedTestServiceInterface] using Dio.
///
/// Downloads a known large file and calculates the download speed in megabits per second (Mbps).
class NetworkSpeedTestService implements NetworkSpeedTestServiceInterface {
  /// Dio instance used to perform the download. Can be injected for testing or customization.
  final Dio _dio;

  /// Cancel token for stopping ongoing speed tests
  CancelToken? _cancelToken;

  /// Flag to track if a test is currently active and callbacks should be invoked
  bool _isTestActive = false;

  /// Creates a new [NetworkSpeedTestService] with an optional custom Dio instance.
  NetworkSpeedTestService({Dio? dio}) : _dio = dio ?? _createDio();

  /// Creates a Dio instance with proper SSL configuration for speed tests.
  static Dio _createDio() {
    final dio = Dio();

    // Configure SSL certificate handling for Android
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
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

  /// Performs a multi-iteration speed test to accurately measure download speed.
  ///
  /// This method improves measurement accuracy by:
  /// 1. Performing a warmup HEAD request to establish connections (DNS, TCP, SSL)
  /// 2. Running multiple download iterations to collect speed samples
  /// 3. Calculating the median speed to filter out outliers
  /// 4. Adding small delays between runs to avoid overwhelming the network
  ///
  /// The median is used instead of average to make the result more robust against
  /// temporary network spikes or drops during any single test run.
  ///
  /// Parameters:
  /// - [file]: The test file to download
  /// - [iterations]: Number of test runs (default: 3)
  /// - [onProgress]: Optional callback for tracking download progress per iteration
  ///
  /// Returns a formatted speed string (e.g., "12.87 Mbps").
  /// Throws [HttpException] if all iterations fail to complete.
  ///
  /// Example:
  /// ```dart
  /// final speed = await service.testDownloadSpeed(
  ///   SpeedTestFile.hetzner100MB,
  ///   iterations: 5,
  ///   onProgress: (received, total) => print('Progress: $received/$total'),
  /// );
  /// print('Speed: $speed'); // "45.32 Mbps"
  /// ```
  @override
  Future<String> testDownloadSpeed(
    SpeedTestFile file, {
    int iterations = 3,
    void Function(int received, int total)? onProgress,
  }) async {
    // Create a new cancel token for this test
    _cancelToken = CancelToken();
    _isTestActive = true;
    final speeds = <double>[];

    // Warmup request (not counted)
    try {
      await _dio.head(
        file.urlString,
        cancelToken: _cancelToken,
      );
    } catch (_) {}

    // Perform multiple test runs
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();

      try {
        final response = await _dio.get<List<int>>(
          file.urlString,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: onProgress != null
              ? (received, total) {
                  // Only call progress callback if test is still active and not cancelled
                  if (_isTestActive && !(_cancelToken?.isCancelled ?? false)) {
                    onProgress(received, total);
                  }
                }
              : null,
          cancelToken: _cancelToken,
        );

        stopwatch.stop();

        if (response.data != null && response.statusCode == 200) {
          final bitsPerSecond = (response.data!.length * 8) /
              (stopwatch.elapsedMilliseconds / 1000);
          speeds.add(bitsPerSecond);
        }
      } catch (e) {
        stopwatch.stop();
        // Continue with remaining runs even if one fails
      }

      // Small delay between runs
      if (i < 2) await Future.delayed(Duration(milliseconds: 500));
    }

    if (speeds.isEmpty) {
      // Check if it was cancelled
      if (_cancelToken?.isCancelled ?? false) {
        _cancelToken = null;
        _isTestActive = false;
        throw HttpException('Speed test was cancelled');
      }
      _cancelToken = null;
      _isTestActive = false;
      throw HttpException('All speed test runs failed');
    }

    // Use median to avoid outliers
    speeds.sort();
    final medianSpeed = speeds[speeds.length ~/ 2];

    // Clear cancel token and active flag after successful completion
    _cancelToken = null;
    _isTestActive = false;

    return _formatNetworkSpeed(medianSpeed);
  }

  /// Stops any ongoing speed test by cancelling the current download operation.
  ///
  /// This method is safe to call even if no test is currently running.
  /// Once stopped, the test will throw an [HttpException] with message "Speed test was cancelled".
  @override
  void stopTest() {
    _isTestActive = false;
    _cancelToken?.cancel('Speed test stopped by user');
    _cancelToken = null;
  }

  /// Formats a speed value in bits per second to a human-readable string.
  ///
  /// Automatically scales the result to the most appropriate unit:
  /// - Less than 1,000: bps (bits per second)
  /// - Less than 1,000,000: Kbps (kilobits per second)
  /// - Less than 1,000,000,000: Mbps (megabits per second)
  /// - 1,000,000,000 or more: Gbps (gigabits per second)
  ///
  /// Uses 2 decimal places for Kbps, Mbps, and Gbps for precision.
  String _formatNetworkSpeed(double bitsPerSecond) {
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
