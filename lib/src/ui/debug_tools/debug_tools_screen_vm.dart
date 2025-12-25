import 'dart:async';
import 'dart:io';

import 'package:dart_ping/dart_ping.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/model/network_request_storage_interface.dart';
import 'package:network_tracker/src/services/network_info_service.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';
import 'package:network_tracker/src/services/speed_test/speet_test_file.dart';
import 'package:network_tracker/src/ui/common/loading_label/loading_state.dart';
import 'package:network_tracker/src/utils/utils.dart';

/// View model for the Debug Tools screen.
///
/// Manages network diagnostic tools including:
/// - Internet speed testing
/// - Network information fetching (external/local IP)
/// - Host ping testing
class DebugToolsScreenVM {
  // Services
  /// Service for performing network speed tests
  late final NetworkSpeedTestServiceInterface _speedTestService =
      NetworkRequestService.instance.networkSpeedTestService;

  /// Service for fetching network information (IP addresses, location, etc.)
  late final NetworkInfoServiceInterface _ipInfoService = NetworkInfoService();

  /// Storage service for retrieving previously accessed URLs
  late final NetworkRequestStorageInterface storageService =
      NetworkRequestService.instance.storageService;

  // Speed Test State
  /// Currently selected test file for speed testing
  late final ValueNotifier<SpeedTestFile> selectedSpeedTestFile =
      ValueNotifier(speedTestFiles.first);

  /// State of the speed test operation (idle, in progress, completed, error)
  late final ValueNotifier<LoadingState<String?>> speedTestState =
      ValueNotifier(LoadingState());
  late final ValueNotifier<String?> downloadProgress = ValueNotifier(null);

  // Network Info State
  /// State of the network information fetch operation
  late final ValueNotifier<LoadingState<Map<String, dynamic>?>>
      networkInfoState = ValueNotifier(LoadingState());

  // Ping State
  /// Currently selected URL/host for ping testing
  late final ValueNotifier<String> selectedPingUrl = ValueNotifier('');

  /// State of the ping operation (idle, in progress, completed, error)
  late final ValueNotifier<LoadingState<void>> pingState =
      ValueNotifier(LoadingState());

  /// List of ping results collected during the current ping operation
  late final ValueNotifier<List<PingData>> pingResults = ValueNotifier([]);

  /// Active ping instance (used for stopping ongoing pings)
  late Ping? _ping;

  /// Subscription to the ping stream (used for cleanup)
  late StreamSubscription? _pingSubscription;

  /// Available test files for speed testing
  List<SpeedTestFile> get speedTestFiles => SpeedTestFile.values;

  /// List of all previously accessed hosts extracted from stored URLs
  ValueNotifier<List<String>> allHosts = ValueNotifier([]);

  /// Initializes the view model and loads previously accessed hosts
  DebugToolsScreenVM() {
    if (Platform.isIOS) {
      DartPingIOS.register();
    }

    storageService.getUrls().then((urls) {
      allHosts.value = urls.map(_extractHost).toList();
      selectedPingUrl.value =
          allHosts.value.isNotEmpty ? allHosts.value.first : '';
    });
  }

  /// Performs an internet speed test using the currently selected test file.
  ///
  /// Downloads a file and calculates download speed. Updates [speedTestState]
  /// with the result (speed as a formatted string) or error.
  Future<void> testSpeed() async {
    speedTestState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgress);

    try {
      final result = await _speedTestService.testDownloadSpeed(
        selectedSpeedTestFile.value,
        onProgress: (received, total) {
          downloadProgress.value = total > 0
              ? '${(received / total * 100).toStringAsFixed(2)}%'
              : '${(received / 1048576).toStringAsFixed(2)} MB received';
        },
      );

      speedTestState.value = LoadingState(
        loadingProgress: LoadingProgressState.completed,
        result: result,
      );
    } catch (e, s) {
      speedTestState.value = LoadingState(
        loadingProgress: LoadingProgressState.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Fetches network information including external IP, local IP, and location data.
  ///
  /// Retrieves both external IP information (using ip-api.com) and local IP address.
  /// Updates [networkInfoState] with a map containing all network details.
  Future<void> fetchExternalIp() async {
    networkInfoState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgress);
    try {
      final networkInfo = await _ipInfoService.fetchExternalInfo();
      final localIP = await _ipInfoService.fetchLocalIP();
      networkInfo?['local_ip'] = localIP;
      networkInfo?['external_ip'] = networkInfo.remove('query');

      networkInfoState.value = LoadingState(
        loadingProgress: LoadingProgressState.completed,
        result: networkInfo,
      );
    } catch (e, s) {
      networkInfoState.value = LoadingState(
        loadingProgress: LoadingProgressState.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Shares the current network information as a JSON file.
  ///
  /// Only works if network information has been successfully fetched.
  /// Uses the device's share functionality to export the data.
  void shareNetworkInfo() {
    final networkInfo = networkInfoState.value.result;

    if (networkInfo != null) {
      Utils.shareFile(networkInfo, fileName: 'network_info_${DateTime.now()}');
    }
  }

  /// Pings the currently selected host continuously or stops an ongoing ping.
  ///
  /// If a ping is already in progress (stoppable state), this method stops it.
  /// Otherwise, starts a new continuous ping operation that sends ICMP packets
  /// at 1-second intervals. Results are accumulated in [pingResults].
  ///
  /// The host is automatically extracted from the URL if [selectedPingUrl] contains
  /// a full URL (e.g., "https://example.com" becomes "example.com").
  Future<void> pingHost() async {
    if (pingState.value.loadingProgress ==
        LoadingProgressState.inProgressStoppable) {
      // Stop ongoing ping
      _ping?.stop();
      pingState.value = LoadingState(
        loadingProgress: LoadingProgressState.completed,
      );
      _pingSubscription?.cancel();
      _pingSubscription = null;
      _ping = null;
      return;
    }

    // Start new ping
    pingState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgressStoppable);
    pingResults.value = [];

    try {
      _ping = Ping(_extractHost(selectedPingUrl.value), interval: 1);

      _pingSubscription = _ping?.stream.listen((result) {
          final pingResult = pingResults.value.toList();
          pingResult.add(result);
          pingResults.value = pingResult;
      }, onDone: () {
        pingState.value = LoadingState(
          loadingProgress: LoadingProgressState.completed,
        );
      }, onError: (e, s) {
        pingState.value = LoadingState(
          loadingProgress: LoadingProgressState.error,
          error: e,
          stackTrace: s,
        );
      });
    } catch (e, s) {
      pingState.value = LoadingState(
        loadingProgress: LoadingProgressState.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Extracts the hostname from a URL or returns the input if it's already a host.
  ///
  /// Examples:
  /// - "https://example.com/path" → "example.com"
  /// - "http://api.example.com:8080" → "api.example.com"
  /// - "google.com" → "google.com"
  ///
  /// Returns the trimmed input if parsing fails or no valid host is found.
  String _extractHost(String urlOrHost) {
    try {
      // Try to parse as a URI
      final uri = Uri.parse(urlOrHost);

      // If it has a scheme (http/https), extract the host
      if (uri.hasScheme && uri.host.isNotEmpty) {
        return uri.host;
      }

      // If no scheme but has a host, return the host
      if (uri.host.isNotEmpty) {
        return uri.host;
      }

      // Otherwise, return as is (probably already a host)
      return urlOrHost.trim();
    } catch (e) {
      // If parsing fails, return as is
      return urlOrHost.trim();
    }
  }
}
