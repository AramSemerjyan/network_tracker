import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// A service that monitors network connectivity status and exposes updates via a stream.
class NetworkConnectivityService {
  /// Instance of the Connectivity plugin to access network status.
  final _connectivity = Connectivity();

  /// Subscription to connectivity change events.
  late final StreamSubscription<ConnectivityResult> subscription;

  /// Stream controller to broadcast connectivity changes to listeners.
  StreamController<ConnectivityResult> onConnectionStatusChanged =
      StreamController();

  /// Constructor sets up initial status and begins listening to connectivity changes.
  NetworkConnectivityService() {
    // Emit the current connectivity status at initialization.
    _connectivity.checkConnectivity().then((result) {
      // As of connectivity_plus 6.0.4, result is a List<ConnectivityResult>,
      // so we take the first available result.
      onConnectionStatusChanged.add(result.first);
    });

    // Listen to ongoing connectivity changes and emit the first result from the list.
    subscription = _connectivity.onConnectivityChanged
        .map((result) => result.first)
        .listen((result) {
      onConnectionStatusChanged.add(result);
    });
  }

  /// Call this to clean up resources when the service is no longer needed.
  void dispose() {
    subscription.cancel();
  }
}
