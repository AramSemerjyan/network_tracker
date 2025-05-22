import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityService {
  final _connectivity = Connectivity();

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Manual check if needed
  Future<ConnectivityResult> checkNow() => _connectivity.checkConnectivity();
}
