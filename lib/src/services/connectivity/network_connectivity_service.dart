import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors and broadcasts network connectivity status changes.
///
/// Uses the connectivity_plus plugin to detect changes in network connectivity
/// (WiFi, mobile data, ethernet, etc.) and exposes them through a stream that
/// can be listened to by any component in the application.
///
/// The service automatically emits the current connectivity status upon initialization
/// and continues to broadcast any subsequent changes.
///
/// **Important:** Always call [dispose] when done to prevent memory leaks.
///
/// Example usage:
/// ```dart
/// final connectivityService = NetworkConnectivityService();
///
/// // Listen to connectivity changes
/// connectivityService.onConnectionStatusChanged.stream.listen((result) {
///   switch (result) {
///     case ConnectivityResult.wifi:
///       print('Connected to WiFi');
///       break;
///     case ConnectivityResult.mobile:
///       print('Connected to mobile data');
///       break;
///     case ConnectivityResult.none:
///       print('No internet connection');
///       break;
///     default:
///       print('Connected via: $result');
///   }
/// });
///
/// // Clean up when done
/// connectivityService.dispose();
/// ```
class NetworkConnectivityService {
  /// Instance of the Connectivity plugin used to monitor network status.
  ///
  /// Provides access to the device's current connectivity state and
  /// emits events when connectivity changes.
  final _connectivity = Connectivity();

  /// Subscription to connectivity change events from the connectivity_plus plugin.
  ///
  /// This subscription is automatically established in the constructor and
  /// should be canceled via [dispose] to prevent memory leaks.
  late final StreamSubscription<ConnectivityResult> subscription;

  /// Stream controller that broadcasts connectivity status changes to listeners.
  ///
  /// Emits [ConnectivityResult] values whenever the network connectivity changes.
  /// Possible values include:
  /// - `ConnectivityResult.wifi`: Connected via WiFi
  /// - `ConnectivityResult.mobile`: Connected via mobile data (cellular)
  /// - `ConnectivityResult.ethernet`: Connected via wired ethernet
  /// - `ConnectivityResult.bluetooth`: Connected via Bluetooth
  /// - `ConnectivityResult.vpn`: Connected via VPN
  /// - `ConnectivityResult.none`: No internet connection
  ///
  /// Subscribe to `onConnectionStatusChanged.stream` to receive updates.
  StreamController<ConnectivityResult> onConnectionStatusChanged =
      StreamController();

  /// Creates a new [NetworkConnectivityService] and begins monitoring connectivity.
  ///
  /// The constructor performs two actions:
  /// 1. Checks and emits the current connectivity status immediately
  /// 2. Sets up a listener for future connectivity changes
  ///
  /// Note: As of connectivity_plus 6.0.4+, the plugin returns a list of
  /// connectivity results. This service takes the first available result
  /// and broadcasts it to listeners.
  NetworkConnectivityService() {
    // Check and emit the current connectivity status at initialization.
    _connectivity.checkConnectivity().then((result) {
      // The result is a List<ConnectivityResult>, so we take the first one.
      // In most cases, there's only one active connection type.
      onConnectionStatusChanged.add(result.first);
    });

    // Set up a listener for ongoing connectivity changes.
    subscription = _connectivity.onConnectivityChanged
        .map((result) => result.first)
        .listen((result) {
      // Broadcast each connectivity change to all listeners
      onConnectionStatusChanged.add(result);
    });
  }

  /// Disposes of resources and cancels connectivity monitoring.
  ///
  /// This method should be called when the service is no longer needed
  /// to prevent memory leaks. It cancels the connectivity subscription
  /// and closes the stream controller.
  ///
  /// After calling dispose, the service should not be used anymore.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   connectivityService.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    subscription.cancel();
    onConnectionStatusChanged.close();
  }
}
