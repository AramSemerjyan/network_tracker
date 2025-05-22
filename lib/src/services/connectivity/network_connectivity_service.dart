import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityService {
  final _connectivity = Connectivity();
  late final StreamSubscription<ConnectivityResult> subscription;
  StreamController<ConnectivityResult> onConnectionStatusChanged =
      StreamController();

  NetworkConnectivityService() {
    subscription = _connectivity.onConnectivityChanged
        .map((result) => result.first)
        .listen((result) {
      onConnectionStatusChanged.add(result);
    });
  }

  void dispose() {
    subscription.cancel();
  }
}
