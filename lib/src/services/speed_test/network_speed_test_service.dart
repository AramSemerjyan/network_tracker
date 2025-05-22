import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class NetworkSpeedTestServiceInterface {
  TestFile get testFile;

  Future<String> testDownloadSpeed();
}

class TestFile {
  final String name;
  final String urlString;

  const TestFile({
    required this.name,
    required this.urlString,
  });

  factory TestFile.pdf100Mb() {
    return TestFile(
      name: 'PDF 100Mb',
      urlString: 'https://link.testfile.org/PDF100MB',
    );
  }

  factory TestFile.zip70Mb() {
    return TestFile(
      name: 'Zip 70Mb',
      urlString: 'https://link.testfile.org/70MB',
    );
  }
}

class NetworkSpeedTestService implements NetworkSpeedTestServiceInterface {
  @override

  /// A large static file hosted on a CDN. ~70MB
  final TestFile testFile = TestFile.zip70Mb();

  final Dio _dio;

  NetworkSpeedTestService({Dio? dio}) : _dio = dio ?? Dio();

  @override

  /// Measures download speed in megabits per second (Mbps).
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
